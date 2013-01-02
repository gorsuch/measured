module Measured
  module Config
    extend self

    def env!(key)
      ENV[key] || raise("#{key} not in ENV")
    end

    def auth_username
      env!('AUTH_USER')
    end

    def auth_password
      env!('AUTH_PASSWORD')
    end
  end
end
