if LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    fields[:request_id] = request.env['action_dispatch.request_id']
    fields[:visit_id] = @tracer_visit_id if @tracer_visit_id
    fields[:prison] = @tracer_prison if @tracer_prison
  end
end
