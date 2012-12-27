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
      end
    end

    post('/') { parse_events(params[:payload]) }
  end
end
