# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file

require 'facter'

module Cronmon
  class Sysinfo

    def self.get
      self.new
    end

    def initialize
    end

    def hostname
      Facter.hostname
    end

    def data
      Facter.to_hash
    end

  end


end



