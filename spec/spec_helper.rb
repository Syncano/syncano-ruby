require 'bundler'
Bundler.setup

require 'dotenv'
Dotenv.load

require 'rspec-prof' if ENV['SPEC_PROFILE']
require 'syncano'
require 'webmock/rspec'

WebMock.disable_net_connect!

def generate_body(params)
  JSON.generate(params)
end

def endpoint_uri(path)
  [Syncano::Connection.api_root,"v1", path].join("/")
end

# RSpec.configure do |config|
#   config.before(:suite) { $enable_tracing = true }
#
#   config.around(:example) do |example|
#     begin
#       example.run
#     rescue SystemStackError
#       puts $!
#       puts caller
#       raise
#     end
#   end
# end

# $trace_out = open('trace.txt', 'w')
# $enable_tracing = false
# $pried = false
#
# set_trace_func proc { |event, file, line, id, proc_binding, classname|
#                  if $enable_tracing && event == 'call'
#                    $trace_out.puts "#{file}:#{line} #{classname}##{id}"
#                  end
#
#                  if !$pried && proc_binding && proc_binding.eval( "caller.size" ) > 400
#                    $pried = true
#                    require 'pry'
#                    proc_binding.pry
#                  end
#                }
