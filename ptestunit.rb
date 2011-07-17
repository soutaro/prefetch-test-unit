require "socket"

ENV["RAILS_ENV"] = 'test'

args = ARGV.dup

$interept = false

case ARGV.shift
when "server"
  while true
    STDERR.puts "starting"
    system "ruby #{__FILE__} test"
    STDERR.puts "finish"
  end
when "test"
  require "minitest/unit"
  class ::MiniTest::Unit
    # to skip installation of autorun
    @@installed_at_exit = true
  end
  
  require "stringio"
  require "test/unit"
  require "pathname"
  
  require File.expand_path(Dir.pwd + "/config/environment")
  Rails.application.config.cache_classes = false

  $LOAD_PATH.insert(0, Pathname(Rails.root) + "lib")
  $LOAD_PATH.insert(0, Pathname(Rails.root) + "test")
  
  s = TCPServer.open(8080)
  socks = [s]
  
  puts "ready !"
  
  io = s.accept
  
  files = []
  while true
    line = io.gets.chomp
    break if line == ""
    files << line
  end
  
  MiniTest::Unit.output = io
  
  files.each do |f|
    next if f =~ /^-/
    
    begin
      if f =~ /\*/
        FileList[f].to_a.each {|fn| require File.expand_path(fn) }
      else
        require File.expand_path(f)
      end
    end
  end

  MiniTest::Unit.new.run

when "run"
  s = TCPSocket.open("localhost", 8080)
  ARGV.each {|x|
    s.puts x
  }
  s.puts ""
  
  while c = s.read(1)
    print c
  end
end
