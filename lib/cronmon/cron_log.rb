# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

module Cronmon
  class CronLog

    attr_reader :logfile, :results, :label 

    def initialize(label, results_or_timestamp)
      @label = label
      @options = Cronmon.settings
      if(@options.logsdir.blank?)
        raise Cronmon::ConfigurationError, 'Missing configuration settings - logsdir'
      end

      if(results_or_timestamp.is_a?(Hash))
        @logfile = File.join(Cronmon.settings.logsdir, "#{@label}_#{Time.now.utc.to_i}.json")
        @results = results_or_timestamp
      elsif(results_or_timestamp.is_a?(Fixnum))
        @logfile = File.join(Cronmon.settings.logsdir, "#{@label}_#{results_or_timestamp}.json")
        if(File.exists?(@logfile))
          @results = File.read(@logfile)
        else
          raise Cronmon::DataError, "Unable to find the cron log: #{@logfile}"
        end
      else
        raise Cronmon::ConfigurationError, 'Invalid CronLog parameters'
      end
    end

    def dump(hash)
      logpath = Pathname.new(@logfile)
      log_parent_dir = logpath.dirname.to_s
      if(!File.exists?(log_parent_dir))
        FileUtils.mkdir_p(log_parent_dir)
      end
      File.open(@logfile, 'w') {|f| f.write(log.to_json) }
    end

    def post
      client = OAuth2::Client.new(@options.auth.uid, @options.auth.secret, {site: @options.posturi, raise_errors: false})
      if(token = client.client_credentials.get_token)
        postdata = {label: @label, 
                    command: @command, 
                    start: @start,
                    finish: @finish,
                    success: true,
                    stdout: @stdout, 
                    stderr: @stderr}
        response = token.post('cronmons/log', body: postdata)
        # if(response)
        #   if(response.status == 200)
        #     return registration_success(response)
        #   elsif(response.status == 422)
        #     response_data = JSON.parse(response.body)
        #     if(response_data['message'])
        #       response_data['message']
        #     end
        #   else
        #     response
        #   end
        # end
        response
      end      

  end
end