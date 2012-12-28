require 'sinatra/base'

module Measurements
  class Web < Sinatra::Base
    configure do
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
        log(:event_count => events.size) 
        events.each do |e|
          h = KV.parse(e['message'])
          r = carbonator.parse(h)
          write(r)
        end
        200
      end

      def prefix
        ENV['PREFIX'] || 'measurements'
      end

      def socket
        @@socket ||= TCPSocket.new 'carbon.hostedgraphite.com', 2003
      end

      def write(s)
        socket.puts(s)
      end
    end

    post('/') do
      parse_events(params[:payload]) 
    end
  end
end
