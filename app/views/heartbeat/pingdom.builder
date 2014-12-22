xml.pingdom_http_custom_check do
  xml.status "OK"
  xml.response_time @later - @now
end
