#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'sinatra-websocket'

puts "Starting server..."

set :server, 'thin'
set :sockets, []

configure do
  set :public_folder, '.'
end

get '/' do
  

  cmd = "blender -b mball.blend -o //renders/ -F JPEG -x 1 -f 1" 
  begin
    PTY.spawn( cmd ) do |stdout, stdin, pid|
      begin
        # Do stuff with the output here. Just printing to show it works
        stdout.each { |line| print line }
      rescue Errno::EIO
        puts "Errno:EIO error, but this probably just means " +
              "that the process has finished giving output"
      end
    end
  rescue PTY::ChildExited
    puts "The child process exited!"
  end
end

get '/' do
  if !request.websocket?
    send_file File.expand_path('index.html', settings.public_folder)
  else
    request.websocket do |ws|
      ws.onopen do       
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
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


