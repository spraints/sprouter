require_relative "lib/sprouter/ping_check"

check_configs = {
  "go_faster" => { "mode" => "average", "above" => 0.35, "window" => 60 },
  "go_slower" => { "mode" => "all", "below" => 0.3, "window" => 300 },
}
# Something that won't respond.
stat_url = "http://192.168.100.61:12004/data/minibuntu/ping/ping_droprate-8.8.8.8"
# This URL will get a response.
#stat_url = "http://127.0.0.1:4433/sprouter.conf"

log = StringIO.new
logger = Logger.new(log)
check_configs.each do |name, config|
  print "#{name}... "
  logger.info name
  start = Time.now.to_f
  begin
    check = Sprouter::PingCheck.build(config.merge("stat_url" => stat_url))
    check.logger = logger
    print check.triggered?
  rescue => e
    print "#{e.class}: #{e}"
  end
  puts " in #{Time.now.to_f - start} seconds"
end

puts "-"*20, log.string
