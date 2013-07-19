# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

module Cronmon
  class Cron

    attr_accessor :options

    def initialize(label,command)
      @label = label
      @command = command
      @options = Cronmon::Options.load
      if(@options.auth.blank?)
        raise Cronmon::ConfigurationError, 'Missing registration settings'
      end

    end

    def run
      # fake
      @stdout = 'output testing'
      @stderr = 'error testing'
      @start = Time.now.utc - 3600
      @finish = Time.now.utc
      @success = true
    end

    def log
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

end


