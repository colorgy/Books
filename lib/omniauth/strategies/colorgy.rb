require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Colorgy < OmniAuth::Strategies::OAuth2
      include OmniAuth::Strategy

      option :client_options, {
        :site => ENV['CORE_URL'],
        :authorize_url => "/oauth/authorize"
      }

      info do
        raw_info
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/me.json?include=identities').parsed
      end
    end
  end
end
