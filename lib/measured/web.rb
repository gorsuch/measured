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
          # Hosted Graphite seems to have some rate-limiting
          # so we sleep between requests
          sleep sleep_time
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

      def sleep_time
        sleep_time = ENV['SLEEP_TIME'] ? sleep_time.to_f : 0.1
      end
    end

    post('/') do
      # fork because this can take a while
      fork do
        parse_events(params[:payload]) 
      end
      200
    end
  end
end
