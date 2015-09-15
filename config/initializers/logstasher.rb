if LogStasher.enabled
  LogStasher.add_custom_fields_to_request_context do |fields|
    visit = session[:visit] || session[:booked_visit]
    if visit
      fields[:visit_id] = visit.visit_id
      fields[:prison] = visit.prison_name
    end
  end
end
