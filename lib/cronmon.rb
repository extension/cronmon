# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

require 'redcard/1.9'
require 'json'
require 'oauth2'
require "cronmon/version"
require "cronmon/errors"
require 'cronmon/deep_merge' unless defined?(DeepMerge)
require "cronmon/sysinfo"
require "cronmon/options"
require "cronmon/cron"
require "cronmon/registration"


module Cronmon
  class Core

    def self.settings
      if(@settings.nil?)
        @settings = Cronmon::Options.new
        @settings.load!
      end

      @settings
    end
  end


end
