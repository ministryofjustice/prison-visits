if LogStasher.enabled
  LogStasher.add_custom_fields_to_request_context do |fields|
    if visit = session[:visit] || session[:booked_visit]
      fields[:visit_id] = visit.visit_id
      fields[:prison] = visit.prisoner.prison_name
    end
  end
end
