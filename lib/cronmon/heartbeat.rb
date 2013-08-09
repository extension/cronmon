# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

module Cronmon
  class Heartbeat

    def self.post(post_sysinfo = true)
      hb = self.new
      hb.post(post_sysinfo)
      hb
    end

    def initialize
      @posted = false
      @options = Cronmon.settings
      @sysinfo = Cronmon::Sysinfo.get
    end

    def post(post_sysinfo = true)
      if(post_sysinfo)
        postdata = {'sysinfo' => @sysinfo.data}
      else
        postdata = {'heartbeat' => true}
      end

      if(token = self.token)
        begin
          response = token.post('cronmons/heartbeat', :body => postdata)
          if(response)
            if(response.status == 200)
              return post_success
            elsif(response.status == 422)
              # possible this throws an exception if we don't get JSON, not catching for now
              response_data = JSON.parse(response.body)
              if(response_data['message'])
                return post_failed(response_data['message'])
              else
                return post_failed("Received an Unprocessable Entity error, but no error message.")
              end
            elsif(response.status == 401)
              return post_failed('Unauthorized request')
            else
              return post_failed("An unknown error occurred. Response code: #{response.status}")
            end
          end
        rescue Faraday::Error::ConnectionFailed => e
          return post_failed(e.message)
        end
      else
        return post_failed("Unable to get an OAuth Token from #{@options.posturi}")
      end          
    end

    def token
      if(@token.nil?)
        client = OAuth2::Client.new(@options.auth.uid, @options.auth.secret, {:site => @options.posturi, :raise_errors => false})
        begin
          @token = client.client_credentials.get_token
        rescue Faraday::Error::ConnectionFailed => e
          return nil
        end
      end
      @token
    end      

    def post_success
      @posted = true
      Cronmon.logger.info("HEARTBEAT: Sent to #{@options.posturi}")
      return true
    end      

    def post_failed(message)
      @error = message
      Cronmon.logger.error("HEARTBEAT: #{message}")
      return false
    end

    def error
      @error
    end

    def posted?
      @posted
    end

  end
end