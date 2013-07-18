# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

module Cronmon
  class Registration

    AUTH_CONFIG_FILE = '/etc/cronmon/auth.toml'
  
    def initialize(secret,site)
      @uid = 'cronmon-registration'
      @secret = secret
      @site = site
      sysinfo = Cronmon::Sysinfo.get
      @hostname = sysinfo.hostname
    end

    def register(force = false)
      client = OAuth2::Client.new(@uid, @secret, {site: @site, raise_errors: false})
      if(token = client.client_credentials.get_token)
        data = {hostname: @hostname}
        if(force)
          data[:force] = true
        end
        response = token.post('cronmons/register', body: data)

        if(response)
          if(response.status == 200)
            return registration_success(response)
          elsif(response.status == 422)
            response_data = JSON.parse(response.body)
            if(response_data['message'])
              response_data['message']
            end
          else
            response
          end
        end
      end
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
      'ok'
    end      


  end
end