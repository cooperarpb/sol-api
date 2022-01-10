require './lib/api_blockchain/client'
require './lib/api_blockchain/response'

module Blockchain
  module Proposal
    class GetAll
      ENDPOINT = "/api/Proposal"

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

          # if Rails.env.production?
          #   @client.request(verb: verb, endpoint: self.class::ENDPOINT, params: nil)
          # else
          #   bc = Struct.new(:success?)
          #   bc.new(true)
          # end
        end
      end
    end
  end
end
