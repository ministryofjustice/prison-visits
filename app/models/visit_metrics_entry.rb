class VisitMetricsEntry < ActiveRecord::Base
  validates_presence_of :visit_id, :prison_name, :requested_at
end
