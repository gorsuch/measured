module Measured
  module Config
    extend self

    def env!(key)
      ENV[key] || raise("#{key} not in ENV")
    end

    def auth_token
      env!('AUTH_TOKEN')
    end

    def deploy
      ENV['DEPLOY'] || 'dev'
    end

    def statsd_url
      env!('STATSD_URL')
    end
  end
end
