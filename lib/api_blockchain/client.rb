require './lib/api_base/client'

module ApiBlockchain
  class Client < ApiBase::Client
    attr_reader :token

    # override to remove token_auth
    def request(verb: 'POST', endpoint:, params: {})
      request_params = OpenStruct.new(verb: verb, endpoint: endpoint, params: params)
      make_request(request_params)
    end

    # XXX: Atualmente o endpoint "/sdc/login" da API REST criada para a blockchain na versão Hyperledger Fabric 2.2
    # utiliza um payload gravado na mesma API. Deve-se alterar e enviar o payload.
    def token_request(verb: 'POST', endpoint: '/api/login', params: {})
      request_params = OpenStruct.new(verb: verb, endpoint: endpoint, params: params)
      @token_request ||= make_request(request_params)
      @token = @token_request.body[0][:token]
      @token_request
    end

    def new_connection(request)
      jwt_conn
    end

    def jwt_conn
      @jwt_conn = Faraday.new(url: base_path) do |conn|
        conn.options.params_encoder = Faraday::FlatParamsEncoder
        conn.options.timeout = 1800
        conn.use :cookie_jar
        conn.authorization(:Bearer, @token) if @token.present?
        conn.response :json, content_type: /\bjson$/, parser_options: { symbolize_names: true }
        conn.request :json
        conn.adapter @adapter
      end
    end

    def base_path
      @base_path ||= Rails.application.secrets.dig(:blockchain, :hyperledger_path)
    end

    def mount_response(response)
      ApiBlockchain::Response.new(status: response.status, body: response.body, verb: verb(response))
    end

    def verb(response)
      response.env.method.to_s.upcase
    end
  end
end