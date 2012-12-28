require 'sinatra/base'

module Measurements
  class Web < Sinatra::Base
    configure do
      Scrolls.global_context(:app => 'measurements', :deploy => ENV['DEPLOY'] || 'dev')
      @@carbonator = nil
      @@socket = nil
    end

    helpers do
      def carbonator
        @@carbonator ||= Carbonator::Parser.new(:prefix => prefix)
      end

      def log(data, &blk)
        Scrolls.log(data, &blk)
      end

      def parse_events(body)
        data = JSON.parse(body)
        events = data['events']
        log(:events => events.size) 
        socket = TCPSocket.new 'carbon.hostedgraphite.com', 2003
        events.sort_by do |e|
          Time.parse(e['received_at'])
        end.each do |e|
          h = KV.parse(e['message'])
          r = carbonator.parse(h)
          socket.puts(r)
          sleep 0.05
        end
        socket.close
      end

      def prefix
        ENV['PREFIX'] || 'measurements'
      end
    end

    post('/') do
      fork do
        parse_events(params[:payload]) 
      end
      200
    end
  end
end
