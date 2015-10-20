class VisitorsDetailsController < ApplicationController
  include CookieGuard
  include SessionGuard::OnEditAndUpdate
  include TrimParams

  before_action :ensure_visit_integrity, only: [:edit, :update]
  before_action :logstasher_add_visit_id_from_session

  def edit
    visit.visitors = [Visitor.new] if visit.visitors.empty?
    @collect_phone_number = true
  end

  def update
    visit.visitors = build_visitors

    go_forward = visit.visitors.all?(&:valid?) && visit.valid?(:visitors_set)

    if params[:next] == 'Add another visitor'
      prepare_next_visitor
    else
      redirect_to go_forward ? edit_slots_path : edit_visitors_details_path
    end
  end

  private

  def prepare_next_visitor
    if visit.visitors.size < Visit::MAX_VISITORS
      visit.visitors << Visitor.new
    else
      flash[:notice] = I18n.t(:max_visitors, scope: 'controllers.shared')
    end
    redirect_to edit_visitors_details_path
  end

  def build_visitors
    visitors_params.
      reject { |h| h[:_destroy].present? }.
      map.with_index { |h, i| Visitor.new(h.merge(index: i)) }
  end

  def visitors_params
    params.require(:visit).require(:visitor)
  end
end
