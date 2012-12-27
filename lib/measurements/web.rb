require 'sinatra/base'

module Measurements
  class Web < Sinatra::Base
    helpers do
      def log(data, &blk)
        Scrolls.log(data, &blk)
      end

      def parse_events(body)
        data = JSON.parse(body)
        events = data['events']
        log(:event_count => events.size) 
        events.each do |e|
          h = KV.parse(e['message'])
          log(h)
        end
      end
    end

    post('/') do
      parse_events(params[:payload]) 
      'ok'
    end
  end
end
