#!/usr/bin/env ruby

require 'sinatra'
require 'json'

puts "Starting server..."



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
    # if @os == :windows
    #   res = run_win(command)
    # else
    #   res = run_shell(command)
    # end
    # res
    `#{command}`
  end 
  
  # def run_shell(command)
  #   #system(command)
  #   system("ifconfig")
  # end

  # def run_win(command)
  #   `#{command}`    
  # end 
  
end    


configure do
  set :public_folder, '.'
end

cr = CommandRunner.new

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

post '/run' do  
  request.body.rewind
  rb = JSON.parse(request.body.read)
  res = cr.run_command(rb["command"])
  res.gsub(/(?:\n\r?|\r\n?)/, '<br>')
end

post '/login' do

end

post '/logout' do
  
end
 
get '/status' do

end


