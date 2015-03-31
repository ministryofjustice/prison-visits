class FixPrisonNames < ActiveRecord::Migration
  def change
    {
      'Albany' => 'Isle of Wight - Albany',
      'Bullingdon' => 'Bullingdon (Convicted Only)',
      'Highpoint' => 'Highpoint North',
      'Liverpool' => 'Liverpool Social Visits',
      'Parkhurst' => 'Isle of Wight - Parkhurst'
    }.each_pair do |from, to|
      VisitMetricsEntry.where(prison_name: from).update_all(prison_name: to)
    end
  end
end
