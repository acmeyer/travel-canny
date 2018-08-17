Analytics = Segment::Analytics.new({
  write_key: ENV['ANALYTICS_API_KEY'],
  on_error: Proc.new { |status, msg| print msg }
})