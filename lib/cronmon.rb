# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

require 'yaml'
require 'json'
require 'oauth2'
require "cronmon/version"
require 'cronmon/deep_merge' unless defined?(DeepMerge)
require "cronmon/sysinfo"
require "cronmon/options"
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
