require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Proposal
    class Get < Base
       def self.call(proposal_id)
        new(proposal_id).call
      end

      def initialize(proposal_id)
        @proposal_id = proposal_id
        @client = ApiBlockchain::Client.new
      end

       def call
        get_proposal!
      end

       private

       def get_proposal!
        request
      end

      # gets doenst need params
      def params; end

      def id
        @proposal_id
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
