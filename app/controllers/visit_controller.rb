class VisitController < ApplicationController
  before_filter :check_if_cookies_enabled, only: [:update_prisoner_details]
  before_filter :check_if_session_timed_out, only: [:update_prisoner_details, :update_visitor_details, :update_choose_date_and_time, :update_check_your_request]
  before_filter :check_if_session_exists, except: [:prisoner_details, :unavailable]
  helper_method :just_testing?
  helper_method :visit

  def check_if_cookies_enabled
    unless cookies['cookies-enabled']
      redirect_to cookies_disabled_path
      return
    end
  end

  def check_if_session_timed_out
    unless visit
      redirect_to(prisoner_details_path, notice: 'Your session timed out because no information was entered for more than 20 minutes.')
      return
    end
    verify_authenticity_token
  end

  def visit
    session[:visit]
  end

  def check_if_session_exists
    unless visit
      redirect_to(prisoner_details_path)
      return
    end
  end

  def prisoner_details
    session[:visit] ||= Visit.new(prisoner: Prisoner.new, visitors: [Visitor.new], slots: [], visit_id: (visit_id = SecureRandom.hex))
    session[:just_testing] = params[:testing].present?
    logstasher_add_visit_id(visit_id)
    response.set_cookie 'cookies-enabled', 1
  end

  def update_prisoner_details
    if (visit.prisoner = Prisoner.new(prisoner_params)).valid?
      redirect_to visitor_details_path
    else
      redirect_to prisoner_details_path
    end
  end

  def visitor_details
  end

  def update_visitor_details
    if m = params[:next].match(/remove-(\d)/)
      index = m[1].to_i
      visit.visitors.delete_at(index)
      redirect_to visitor_details_path
      return
    end

    visit.visitors = []
    visit_params.each_with_index do |visitor_hash, i|
      visit.visitors << Visitor.new(visitor_hash.merge(index: i)) unless visitor_hash[:_destroy].present?
    end
    go_back = visit.visitors.select do |v|
      !v.valid?
    end.any?

    go_back = !visit.valid?(:visitors_set) || go_back

    if params[:next] == 'Add another visitor'
      if visit.visitors.size < Visit::MAX_VISITORS
        visit.visitors << Visitor.new
        redirect_to visitor_details_path
      else
        redirect_to visitor_details_path, notice: "You may only have a maximum of #{Visit::MAX_VISITORS} visitors"
      end
    else
      redirect_to go_back ? visitor_details_path : choose_date_and_time_path
    end
  end

  def choose_date_and_time
    @slots = visit.slots.empty? ? [Slot.new, Slot.new, Slot.new] : visit.slots
  end

  def update_choose_date_and_time
    visit.slots = []
    slot_params.each_with_index do |slot_hash, i|
      visit.slots << Slot.new(slot_hash_from_string(slot_hash[:slot]).merge(index: i))
    end
    
    go_back = visit.slots.select do |slot|
      !slot.valid?
    end.any? || visit.slots.size > Visit::MAX_SLOTS

    go_back = !visit.valid?(:date_and_time) || go_back

    if go_back
      redirect_to choose_date_and_time_path
    else
      redirect_to check_your_request_path
    end
  end

  def check_your_request
  end

  def update_check_your_request
    unless just_testing?
      @token = encryptor.encrypt_and_sign(visit)
      PrisonMailer.booking_request_email(visit, @token, request.host).deliver
      VisitorMailer.booking_receipt_email(visit).deliver
    end

    metrics_logger.record_visit_request(visit)
    redirect_to request_sent_path
  end

  def request_sent
    render
    reset_session
  end

  def abandon
    reset_session
  end

private

  def metrics_logger
    METRICS_LOGGER
  end

  def encryptor
    MESSAGE_ENCRYPTOR
  end

  def visit_params
    dob = [:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)']
    params[:visit][:visitor].each do |visitor|
      if visitor[:date_of_birth_native].present?
        date_of_birth = visitor[:date_of_birth_native]
        dob.push(:date_of_birth_native).map{|d| visitor.delete(d)}
      else
        date_of_birth = dob.map do |key|
          visitor.delete(key).to_i
        end
        visitor.delete(:date_of_birth_native)
      end
      begin
        visitor[:date_of_birth] = Date.new(*date_of_birth.reverse)
      rescue ArgumentError
        # NOOP
      end
    end
    trim_whitespace_from_values(params.require(:visit).require(:visitor))
  end

  def prisoner_params
    dob = [:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)']
    if params[:date_of_birth_native].present?
      params[:prisoner][:date_of_birth] = Date.parse(params[:date_of_birth_native])
      dob.map{|d| params[:prisoner].delete(d)}
    else
      date_of_birth = dob.map do |key|
        params[:prisoner].delete(key).to_i
      end
      params[:prisoner][:date_of_birth] = Date.new(*date_of_birth.reverse)
    end
    trim_whitespace_from_values(params.require(:prisoner).permit(:first_name, :last_name, :date_of_birth, :number, :prison_name))
  rescue ArgumentError
    trim_whitespace_from_values(params.require(:prisoner).permit(:first_name, :last_name, :number, :prison_name))
  end

  def slot_params
    params.require(:visit).require(:slots)
  end

  def slot_hash_from_string(str)
    # From 2013-11-02-0945-1115
    # To { date: '2013-11-02', times: '0945-1115' }
    segments = str.split('-')
    if segments.length.zero?
      { date: '', times: '' }
    else
      {
        date: segments[0..2].join('-'),
        times: segments[3..4].join('-')
      }
    end
  end

  def just_testing?
    session[:just_testing]
  end

  def trim_whitespace_from_values(p)
    case p
    when Hash
      p.inject(p.class.new) do |h, (k, v)|
        if v.is_a?(String)
          h[k] = v.strip
        else
          h[k] = trim_whitespace_from_values(v)
        end
        h
      end
    when Array
      p.map do |v|
        trim_whitespace_from_values(v)
      end
    else
      p
    end
  end
end
