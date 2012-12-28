require 'sinatra/base'

module Measured
  class Web < Sinatra::Base
    configure do
      Scrolls.global_context(:app => 'measurements', :deploy => ENV['DEPLOY'] || 'dev')
    end

    helpers do
      def carbon_url
        ENV['CARBON_URL'] || 'tcp://carbon.hostedgraphite.com:2003'
      end

      def log(data, &blk)
        Scrolls.log(data, &blk)
      end

      def parse_events(body)
        data = JSON.parse(body)
        events = data['events']
        log(:events => events.size) 
        carbonator = new_carbonator
        socket = new_socket
        events.each do |e|
          h = KV.parse(e['message'])
          r = carbonator.parse(h)
          socket.puts(r)
          sleep 0.05
        end
        socket.close
      end

      def new_carbonator
        Carbonator::Parser.new(:prefix => prefix)
      end

      def new_socket
        uri = URI.parse(carbon_url)
        TCPSocket.new uri.host, uri.port
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
