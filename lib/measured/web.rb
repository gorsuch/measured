require 'sinatra/base'

module Measured
  class Web < Sinatra::Base
    configure do
      Scrolls.global_context(:app => 'measurements', :deploy => ENV['DEPLOY'] || 'dev')
    end

    helpers do
      def statsd_url
        ENV['STATSD_URL'] || raise("STATSD_URL not defined in ENV")
      end

      def log(data, &blk)
        Scrolls.log(data, &blk)
      end

      def parse_events(body)
        data = JSON.parse(body)
        events = data['events']
        log(:events => events.size) 
        events.each do |e|
          m = Statsdeify::Measurement.from_line(e)
          writer.puts(m) if m
        end
        200
      end

      def writer
        @writer ||= Statsdeify::Writer.new(statsd_url)
      end
    end

    post('/') do
      parse_events(params[:payload]) 
    end
  end
end
