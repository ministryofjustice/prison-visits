module VisitorsManipulator
  extend ActiveSupport::Concern

  included do
    before_filter :adjust_visitors_in_session, only: :edit
    before_filter :logstasher_add_visit_id_from_session
  end

  def adjust_visitors_in_session
    visit.visitors = [model_class.new] if visit.visitors.empty?
  end

  def update
    m = params[:next].match(/remove-(\d)/)
    if m
      index = m[1].to_i
      visit.visitors.delete_at(index)
      redirect_to this_path
      return
    end

    visit.visitors = build_visitors

    go_forward = visit.visitors.all?(&:valid?) && visit.valid?(:visitors_set)

    if params[:next] == 'Add another visitor'
      prepare_next_visitor
    else
      redirect_to go_forward ? next_path : this_path
    end
  end

  def prepare_next_visitor
    if visit.visitors.size < Visit::MAX_VISITORS
      visit.visitors << model_class.new
    else
      flash[:notice] = I18n.t(:max_visitors, scope: 'controllers.shared')
    end
    redirect_to this_path
  end

  private

  def build_visitors
    visitors_params.
      reject { |h| h[:_destroy].present? }.
      map.with_index { |h, i| model_class.new(h.merge(index: i)) }
  end

  def visitors_params
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
      rescue ArgumentError => e
        logger.error "Visitor DOB issue (VisitorsManipulator): " \
          "#{date_of_birth.inspect}\nexception: #{e}"
      end
    end
    ParamUtils.trim_whitespace_from_values(
      params.require(:visit).require(:visitor)
    )
  end
end
