# === COPYRIGHT:
# Copyright (c) 2013 North Carolina State University
# === LICENSE:
# see LICENSE file
require 'thor'
require 'cronmon'
require 'highline'

module Cronmon
  class CLI < Thor
    include Thor::Actions
    include Cronmon
  

    no_tasks do

      def ask_password(message)
        HighLine.new.ask(message) do |q| 
          q.echo = '*'
        end
      end

    end


    desc "about", "about cronomon"
    def about
      puts "Cronmon Version #{Cronmon::VERSION}: Cron tracking and logging."
    end

    desc "register", "Register cronmon on this host"
    method_option :key, :default => 'prompt', :aliases => "-k", :desc => "Registration key"
    method_option :force, :default => false, :aliases => "-f", :desc => "Force registration"
    def register
      if(options[:key] == 'prompt')
        registration_key = ask_password('Registration key: ')
      else
        registration_key = options[:key]
      end

      result = Cronmon::Registration.register(registration_key,options[:force])
      puts "#{result}"
    end

    desc "showsettings", "Show settings"
    def showsettings
      require 'pp'
      @options = Cronmon::Options.load
      pp @options.to_hash
    end

  end
end