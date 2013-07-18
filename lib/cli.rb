# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'thor'
require 'cronmon'

module Cronmon
  class CLI < Thor
    include Thor::Actions
    include Cronmon
    default_task :about
  

    desc "about", "about cronomon"
    def about
      puts "Cronmon Version #{Cronmon::VERSION}: Cron tracking and logging."
    end

  end
end