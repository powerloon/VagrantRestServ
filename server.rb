#!/usr/bin/env ruby

require 'sinatra'
require 'json'

puts "Starting server..."

configure do    

  class CommandRunner  
    def initialize  
      # Instance variables  
      @os ||= (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
      )  
    end  
    
    def run_command(command)
      if @os == :windows
        res = run_win(command)
      else
        res = run_shell(command)
      end
      res
    end 
    
    def run_shell(command)
      #system(command)
      system("ifconfig")
    end

    def run_win(command)
      `"#{command}"`
    end 
    
  end
 
end

get '/' do
  #send_file File.expand_path('index.html', settings.public_folder)
  @cr = CommandRunner.new
  res = @cr.run_command(nil)
  puts typeof res
  res = res.to_s
  res
end

post '/login' do

end

post '/logout' do
  
end
 
get '/status' do

end


