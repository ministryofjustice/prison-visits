xml.pingdom_http_custom_check do
  xml.status "OK"
  xml.response_time sprintf("%5.3f", (@later - @now) * 1000)
end
