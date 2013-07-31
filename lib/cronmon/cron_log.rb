# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

module Cronmon
  class CronLog

    attr_reader :logfile, :results, :label, :logtime, :posted

    def initialize(label, results_or_timestamp)
      @posted = false
      @label = label
      @options = Cronmon.settings
      if(@options.logsdir.empty?)
        raise Cronmon::ConfigurationError, 'Missing configuration settings - logsdir'
      end

      if(results_or_timestamp.is_a?(Hash))
        @logtime = Time.now.utc
        @logfile = File.join(Cronmon.settings.logsdir, "#{@label}_#{@logtime.to_i}.json")
        @results = results_or_timestamp
        @metadata = {'label' => @label}
      elsif(results_or_timestamp.is_a?(Fixnum))
        @logtime = Time.at(results_or_timestamp).utc
        @logfile = File.join(Cronmon.settings.logsdir, "#{@label}_#{@logtime.to_i}.json")
        if(File.exists?(@logfile))
          logdata = JSON.parse(File.read(@logfile))
          @metadata = logdata['metadata']
          @results = logdata['results']
        else
          raise Cronmon::DataError, "Unable to find the cron log: #{@logfile}"
        end
      else
        raise Cronmon::ConfigurationError, 'Invalid CronLog parameters'
      end
    end

    def dump
      logpath = Pathname.new(@logfile)
      log_parent_dir = logpath.dirname.to_s
      if(!File.exists?(log_parent_dir))
        FileUtils.mkdir_p(log_parent_dir)
      end
      logdata = {'metadata' => @metadata, 'results' => @results}
      File.open(@logfile, 'w') {|f| f.write(logdata.to_json) }
    end

    def post
      if(token = self.token)
        response = token.post('cronmons/log', body: @results)
        if(response)
          if(response.status == 200)
            if(File.exists?(@logfile))
              # in the event we posted an existing logfile
              File.unlink(@logfile)
            end
            @posted = true
            return true
          elsif(response.status == 422)
            response_data = JSON.parse(response.body)
            if(response_data['message'])
              return post_failed(response_data['message'])
            else
              return post_failed(response.body)
            end
          elsif(response.status == 401)
            return post_failed('Unauthorized request')
          else
            return post_failed(response.body)
          end
        end
      end
    end

    def token
      if(@token.nil?)
        client = OAuth2::Client.new(@options.auth.uid, @options.auth.secret, {site: @options.posturi, raise_errors: false})
        @token = client.client_credentials.get_token
      end
      @token
    end      


    def post_failed(message)
      @metadata['error'] = message
      @metadata['failcount'] ||= 0
      @metadata['failcount'] += 1
      self.dump
      return false
    end

    def error
      @metadata['error']
    end

    def posted?
      @posted
    end


  end
end