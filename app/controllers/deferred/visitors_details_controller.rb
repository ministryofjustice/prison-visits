class Deferred::VisitorsDetailsController < ApplicationController
  def edit
  end

  def update
    if m = params[:next].match(/remove-(\d)/)
      index = m[1].to_i
      visit.visitors.delete_at(index)
      redirect_to edit_deferred_visitors_details_path
      return
    end

    visit.visitors = []
    visitors_params.each_with_index do |visitor_hash, i|
      visit.visitors << Visitor.new(visitor_hash.merge(index: i)) unless visitor_hash[:_destroy].present?
    end
    go_back = visit.visitors.select do |v|
      !v.valid?
    end.any?

    go_back = !visit.valid?(:visitors_set) || go_back

    if params[:next] == 'Add another visitor'
      if visit.visitors.size < Visit::MAX_VISITORS
        visit.visitors << Visitor.new
        redirect_to edit_deferred_visitors_details_path
      else
        redirect_to edit_deferred_visitors_details_path, notice: "You may only have a maximum of #{Visit::MAX_VISITORS} visitors"
      end
    else
      redirect_to go_back ? edit_deferred_visitors_details_path : edit_deferred_slots_path
    end
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
      rescue ArgumentError
        # NOOP
      end
    end
    ParamUtils.trim_whitespace_from_values(params.require(:visit).require(:visitor))
  end
end
