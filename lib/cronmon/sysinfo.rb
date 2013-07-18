# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

require 'ohai'

module Cronmon
  class Sysinfo

    attr_reader :data

    def self.get
      self.new
    end

    def initialize
      system = Ohai::System.new
      system.all_plugins
      @data = system.data
    end

    def hostname
      @data['hostname']
    end

  end


end



