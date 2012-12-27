require 'sinatra/base'

module Measurements
  class Web < Sinatra::Base
    configure do
      @@carbonator = nil
    end

    helpers do
      def carbonator
        @@carbonator ||= Carbonator::Parser.new
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
          log(:result => r) if r
        end
        200
      end
    end

    post('/') do
      parse_events(params[:payload]) 
    end
  end
end
