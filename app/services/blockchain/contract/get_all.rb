require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Contract
    class GetAll
      ENDPOINT = "/api/Contract"

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
          @client.request(verb: verb, endpoint: self.class::ENDPOINT, params: nil)
        end
      end
    end
  end
end
