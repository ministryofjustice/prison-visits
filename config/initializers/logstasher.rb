if LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    fields[:request_id] = response['X-Request-Id'] = request.env['action_dispatch.request_id']
    if visit = session[:visit]
      fields[:visit_id] = visit.visit_id
      if prison = visit.prisoner.prison_name
        fields[:prison] = prison
      end
    end
  end
end
