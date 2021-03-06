require 'sinatra/base'

module Measured
  class Web < Sinatra::Base
    configure do
      Scrolls.global_context(:app => 'measurements', :deploy => Config.deploy)
      @@writer = nil
    end

    helpers do
      def statsd_url
        Config.statsd_url
      end

      def log(data, &blk)
        Scrolls.log(data, &blk)
      end

      def parse_events(body)
        data = JSON.parse(body)
        events = data['events']
        log(:events => events.size) 
        events.each do |e|
          m = Statsdeify::Measurement.from_line(e['message'])
          if m
            begin
              writer.puts(m)
            rescue Errno::ECONNREFUSED => e
              log(:fn => :parse_events, :at => :error, :exception => e.message)
            end
          end
        end
        200
      end

      def writer
        @@writer ||= Statsdeify::Writer.new(statsd_url)
      end
    end

    post('/') do
      return 401 unless params[:auth_token] == Config.auth_token
      parse_events(params[:payload]) 
    end
  end
end
