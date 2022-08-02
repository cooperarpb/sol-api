require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Bidding
    class Get
      attr_accessor :bidding_id
      
      ENDPOINT = "/api/Bidding"

      def self.call(bidding_id)
        new(bidding_id).call
      end

      def initialize(bidding_id)
        @bidding_id = bidding_id
        @client = ApiBlockchain::Client.new
      end

      def call
        request
      end

      private

      def endpoint
        [self.class::ENDPOINT, id].join('/')
      end

      # gets doenst need params
      def params; end

      def id
        bidding_id
      end

      def verb
        'GET'
      end

      def request
        @request ||= begin
          @client.token_request
          @client.request(verb: verb, endpoint: endpoint, params: params)
        end
      end
    end
  end
end
