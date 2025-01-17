require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Bidding
    class GetAll

      ENDPOINT = "/api/Bidding"

      def self.call
        new.call
      end

      def initialize
        @client = ApiBlockchain::Client.new
      end

      def call
        request
      end

      private

      def verb
        'GET'
      end

      def request
        @request ||= begin
          @client.token_request
          @client.request(verb: verb, endpoint: self.class::ENDPOINT, params: nil)
        end
      end
    end
  end
end
