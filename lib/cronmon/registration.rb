# -*- encoding: utf-8 -*-
# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

module Cronmon
  class Registration

    attr_reader :hostname

    def self.register(secret,force=false)
      registration = self.new(secret)
      registration.register(force)
      registration
    end
  
    def initialize(secret)
      @uid = 'cronmon-registration'
      @secret = secret
      @options = Cronmon.settings
      sysinfo = Cronmon::Sysinfo.get
      @hostname = sysinfo.hostname
      @success = false
    end

    def token
      if(@token.nil?)
        client = OAuth2::Client.new(@uid, @secret, {site: @options.posturi, raise_errors: false})
        begin
          @token = client.client_credentials.get_token
        rescue Faraday::Error::ConnectionFailed => e
          return nil
        end
      end
      @token
    end       

    def register(force = false)

      if(token = self.token)
        data = {hostname: @hostname}
        if(force)
          data[:force] = true
        end

        begin
          response = token.post('cronmons/register', body: data)
          if(response)
            if(response.status == 200)
              return registration_success(response)
            elsif(response.status == 422)
              # possible this throws an exception if we don't get JSON, not catching for now
              response_data = JSON.parse(response.body)
              if(response_data['message'])
                return registration_failed(response_data['message'])
              else
                return registration_failed("Received an Unprocessable Entity error, but no error message.")
              end
            elsif(response.status == 401)
              return registration_failed('Unauthorized request – did you specify the correct registration key?')
            else
              return registration_failed("An unknown error occurred. Response code: #{response.status}")
            end
          end
        rescue Faraday::Error::ConnectionFailed => e
          return registration_failed(e.message)
        end
      else
        return registration_failed("Unable to get an OAuth Token from #{@options.posturi}")
      end
    end

    def error
      @error
    end

    def success?
      @success
    end

    def registration_failed(message)
      @error = message
      Cronmon.logger.error("REGISTRATION: #{message}")
      return false
    end      

    def registration_success(response)
      response_data = JSON.parse(response.body)
      if(response_data['auth'])
        authpath = Pathname.new(AUTH_CONFIG_FILE)
        config_dir = authpath.dirname.to_s
        if(!File.exists?(config_dir))
          FileUtils.mkdir(config_dir)
        end

        File.open(AUTH_CONFIG_FILE,'w') do |file|
          file.write(TOML.dump({:auth => response_data['auth']}))
        end
      end
      Cronmon.logger.info("REGISTRATION: Registered system as #{@hostname}")
      @success = true
      return true
    end      


  end
end