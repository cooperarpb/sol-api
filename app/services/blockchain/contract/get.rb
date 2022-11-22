require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Contract
    class Get

      ENDPOINT = "/api/Contract"

      def self.call(contract_id)
        new(contract_id).call
      end

      def initialize(contract_id)
        @contract_id = contract_id
        @client = ApiBlockchain::Client.new
      end

      def call
        request
      end

      # gets doenst need params
      def params; end

      def id
        @contract_id
      end

      private

      def endpoint
        [self.class::ENDPOINT, id].join('/')
      end
      
      def verb
        'GET'
      end

      def request
        @request ||= begin
          @client.token_request
          @client.request(verb: verb, endpoint: endpoint, params: nil)
        end
      end
    end
  end
end
