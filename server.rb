#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'sinatra-websocket'
require 'pty'

puts "Starting server..."

set :server, 'thin'
set :sockets, []

configure do
  set :public_folder, '.'
end

  
get '/' do
  if !request.websocket?
    send_file File.expand_path('index.html', settings.public_folder)
  else
    request.websocket do |ws|
      ws.onopen do       
        settings.sockets << ws
      end
      ws.onmessage do |json|
        data = JSON.parse(json)
        command = data["command"]
        path = data["path"]

        puts "----------------------------------"
        puts "command: #{command}"
        puts "path:    #{path}"


        # if command.length > 0 && path.length > 0

          settings.sockets.each do |s|
            s.send("")
          end
          begin
            t = Thread.new do
              Dir.chdir(path){
                IO.popen(command, :err=>[:child, :out]) do |out|
                  out.each_line do |line|
                    puts line 
                    settings.sockets.each do |s|
                      s.send("#{line}")
                    end
                  end
                end                
              }
            end
          rescue 
            puts "Error sending output"
          end 
        # end
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets.delete(ws)
      end
    end
  end
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


