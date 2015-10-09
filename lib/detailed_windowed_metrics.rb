class DetailedWindowedMetrics < DetailedMetrics
  def initialize(model, nomis_id, date_range)
    super(model, nomis_id)
    @scoped_model_for_histograms = @scoped_model.after(date_range.last)
    @scoped_model =
      @scoped_model.after(date_range.first).before(date_range.last)
  end

  def series(column)
    @scoped_model_for_histograms.where.not(column => nil).pluck(column)
  end

  def waiting_times
    @scoped_model_for_histograms.waiting.
      pluck("EXTRACT(epoch FROM NOW() - requested_at) AS delay")
  end
end
