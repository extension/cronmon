# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'open3'

module Cronmon
  class Cron

    attr_accessor :results

    def initialize(label,command)
      @options = Cronmon.settings
      @label = label
      @command = command
      if(@options.auth.empty?)
        raise Cronmon::ConfigurationError, 'Missing registration settings'
      end
      @results = {}
    end

    def run
      @results['label'] = @label
      @results['command'] = @command
      @results['start'] = Time.now.utc
      stdin, stdout, stderr = Open3.popen3(@command)
      stdin.close
      @results['stdout'] = stdout.read
      @results['stderr'] = stderr.read
      @results['finish'] = Time.now.utc
      @results['runtime'] = (@results['finish'] - @results['start'])
      @results['success'] = @results['stderr'].empty?
      @results['success']
    end


    def log
      cronlog = Cronmon::CronLog.new(@label,@results)
      cronlog.post
      cronlog
    end
  end

end


