require 'rubygems'
require 'getoptlong'
require 'open3'
require 'socket'
require 'json'
require 'rest-client'

# specify the options we accept and figure out what we got
progopts = GetoptLong.new(
  [ "--name","-n", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--verbose","-v", GetoptLong::NO_ARGUMENT ],
  [ "--runcommand","-r", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--debug","-d", GetoptLong::NO_ARGUMENT ]
)

@verbose = false
@debug = false
@runcommand = ""
@cron_name = ""

progopts.each do |option, arg|
  case option
    when '--debug'
      @debug = true
    when '--verbose'
      @verbose = true
    when '--runcommand'
      @runcommand = arg
    when '--name'
      @cron_name = arg
    else
      puts "Unrecognized option #{opt}"
      exit 0
    end
end

@server_name = Socket::gethostname.split(/\./)[0]
@cronmon_uri = 'http://deploys.extension.org'
@cronmon_path = 'cron_logs/create'
@crondata = nil

def post_crondata
   begin
     response = RestClient.post("#{@cronmon_uri}/#{@cronmon_path}",
                     @crondata.to_json,
                     :content_type => :json, :accept => :json)
   rescue=> e
     response = e.response
   end
   
   if(!response.code == 200)
     return false
   else
     begin
       parsed_response = JSON.parse(response)
       if(parsed_response['success'])
         return true
       else
         return false
       end
     rescue
       return false
     end
   end
 end


def run_cron(command)
   start_time = Time.now
   stdin, stdout, stderr = Open3.popen3(command)
   stdin.close
   stdout_output = stdout.read
   stderr_output = stderr.read
   finish_time = Time.now
   return { :cron_name => @cron_name, :command => @runcommand, :server => @server_name, :stdout => stdout_output, :stderr => stderr_output, :started_at => start_time, :finished_at => finish_time, :runtime => finish_time - start_time }
end

def main()
      
  puts " command to run: #{@runcommand}" if @verbose
  puts " cron name: #{@cron_name}" if @verbose
  @crondata = run_cron(@runcommand) unless @debug
  post_crondata unless @debug
  
end
main
