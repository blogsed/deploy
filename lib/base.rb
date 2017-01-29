require "opal"
require "ext/kernel"

$process = Native(`process`)
$module = Native(`module`)
$exports = $module.exports

# Better exception handlers.
$process.on("uncaughtException", lambda do |error|
  $stderr.print "#{error.class}: "
  $stderr.puts error.to_s
  stack = error.JS["stack"]
  backtrace = stack.split("\n").map { |t| t.match(/\/.*:\d+(?=:)/) }.compact
  backtrace.each { |l| puts "\t#{l}" }
end)
