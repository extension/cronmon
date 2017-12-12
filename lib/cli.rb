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
    method_option :force, :type => :boolean, :default => false, :aliases => "-f", :desc => "Force registration"
    def register
      if(options[:key] == 'prompt')
        registration_key = ask_password('Registration key: ')
      else
        registration_key = options[:key]
      end

      registration = Cronmon::Registration.register(registration_key,options[:force])
      if(registration.success?)
        puts "System registered as #{registration.hostname}"
      else
        puts "Unable to register. Reason: #{registration.error}"
      end
    end

    desc "showsettings", "Show settings"
    def showsettings
      require 'pp'
       @program_options = Cronmon.settings
      pp  @program_options.to_hash
    end

    desc "showenvironment", "Show environment variables in settings"
    def showenvironment
      require 'pp'
       @environment = Cronmon.environment
      pp  @environment.to_hash
    end

    desc "task", "Run a task"
    method_option :label, :aliases => "-l", :desc => 'Task to execute', :required => true
    method_option :quiet, :type => :boolean, :default => false, :aliases => "-q", :desc => "Don't show verbose output"
    def task
      @program_options = Cronmon.settings
      if( @program_options.tasks.nil?)
        puts "Unable to any configured tasks. Please check the program settings (e.g. #{Cronmon::TASKS_CONFIG_FILE})"
        exit
      end
      if(command =  @program_options.tasks.send(options[:label]))
        cron = Cronmon::Cron.new(options[:label],command)
        cron.run
        cronlog = cron.log
        if(cronlog.posted?)
          puts "Cron output for the #{options[:label]} posted to #{ @program_options.posturi}" if(!options[:quiet])
          # go back and try to post previous logs if any exist.
          loglist = Cronmon::CronLog.check_for_logs(options[:label])
          if(!loglist.empty?)
            loglist.each do |logfile|
              if(old_cronlog = Cronmon::CronLog.post_logfile(logfile))
                if(old_cronlog.posted?)
                  puts "Old Cron output for the #{options[:label]} posted to #{ @program_options.posturi}" if(!options[:quiet])
                else
                  # todo: post error if failcount reached
                  puts "Unable to post old cron output, Reason: #{old_cronlog.error}" if(!options[:quiet])
                end
              end
            end
          end
        else
          # todo: post error if failcount reached
          puts "Unable to post cron output, Reason: #{cronlog.error}" if(!options[:quiet])
        end
      else
        puts "Unable to find a command for \"#{options[:label]}\" please check the program settings (e.g. #{Cronmon::TASKS_CONFIG_FILE})"
      end
    end

    desc "tasklist", "Show configured tasks"
    def tasklist
      @program_options = Cronmon.settings
      if( @program_options.tasks.nil?)
        puts "Unable to any configured tasks. Please check the program settings (e.g. #{Cronmon::TASKS_CONFIG_FILE})"
        exit
      end

      puts "Configured tasks:"
      @program_options.tasks.to_hash.each do |label,command|
        puts " #{label} = #{command}"
      end
    end

    desc "heartbeat", "Post heartbeat information"
    method_option :quiet,  :type => :boolean, :default => false, :aliases => "-q", :desc => "Don't show verbose output"
    def heartbeat
      heartbeat = Cronmon::Heartbeat.post
      if(heartbeat.posted?)
        puts "Heartbeat posted." if(!options[:quiet])
      else
        puts "Unable to post heartbeat. Reason: #{heartbeat.error}" if(!options[:quiet])
      end
    end

    desc "rebootcheck", "Post rebootcheck information"
    method_option :quiet,  :type => :boolean, :default => false, :aliases => "-q", :desc => "Don't show verbose output"
    def rebootcheck
      rebootcheck = Cronmon::Rebootcheck.post
      if(rebootcheck.posted?)
        puts "Reboot check posted." if(!options[:quiet])
      else
        puts "Unable to post reboot check. Reason: #{rebootcheck.error}" if(!options[:quiet])
      end
    end

  end
end
