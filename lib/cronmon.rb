# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

require 'redcard/1.9'
require 'json'
require 'oauth2'
require 'logger'
require "cronmon/version"
require "cronmon/errors"
require 'cronmon/deep_merge' unless defined?(DeepMerge)
require "cronmon/sysinfo"
require "cronmon/options"
require "cronmon/cron"
require "cronmon/cron_log"
require "cronmon/registration"
require "cronmon/heartbeat"


module Cronmon

  AUTH_CONFIG_FILE = '/etc/cronmon/auth.toml'
  TASKS_CONFIG_FILE = '/etc/cronmon/tasks.toml'
  SETTINGS_CONFIG_FILE = '/etc/cronmon/settings.toml'

  def self.settings
    if(@settings.nil?)
      @settings = Cronmon::Options.new
      @settings.load!
    end

    @settings
  end

  def self.logger
    options = self.settings
    if(@logger.nil?)
      if(!File.exists?(options.logsdir))
        FileUtils.mkdir_p(options.logsdir)
      end
      @logger = Logger.new("#{options.logsdir}/cronmon.log")
    end
    @logger
  end


end
