module Supp
  class ProvidersController < SuppController
    include TransactionMethods

    PERMITTED_PARAMS = [
      :name,

      address_attributes: [
        :id, :address, :number, :neighborhood, :city_id, :cep, :complement,
        :reference_point, :latitude, :longitude
      ],

      legal_representative_attributes: [
        :id, :name, :nationality, :civil_state, :rg, :cpf, :valid_until,

        address_attributes: [
          :id, :address, :number, :neighborhood, :city_id, :cep, :complement,
          :reference_point, :latitude, :longitude
        ]
      ],

      suppliers_attributes: [
        :id, :phone, :password, :password_confirmation, :avatar, :locale
      ],
    ].freeze

    PERMITTED_PARAMS_WITHOUT_PASSWORD = [
      :name,

      address_attributes: [
        :id, :address, :number, :neighborhood, :city_id, :cep, :complement,
        :reference_point, :latitude, :longitude
      ],

      legal_representative_attributes: [
        :id, :name, :nationality, :civil_state, :rg, :cpf, :valid_until,

        address_attributes: [
          :id, :address, :number, :neighborhood, :city_id, :cep, :complement,
          :reference_point, :latitude, :longitude
        ]
      ],

      suppliers_attributes: [
        :id, :phone, :avatar, :locale
      ],
    ].freeze

    def profile
      if update?
        render status: :ok, json: { supplier: profile_json }
      else
        render status: :unprocessable_entity, json: { errors: current_provider.errors_as_json }
      end
    end

    def find_current_provider
      if current_provider.present?
        render json: current_provider, serializer: Supp::ProviderSerializer, current_supplier: current_supplier
      else
        render status: :unprocessable_entity, json: { errors: "Erro!" }
      end
    end

    private

    def update?
      execute_or_rollback do
        current_provider.update!(provider_params)
        if params_with_password?
          current_user.access_tokens.update_all(revoked_at: DateTime.current)
        end
      end
    end

    def profile_json
      base_profile_json.merge(profile_avatar_json)
    end

    def base_profile_json
      {
        'id'       => current_user.id,
        'name'     => current_user.name,
        'username' => current_user.email,
        'locale'   => current_user.locale
      }
    end

    def profile_avatar_json
      { 'avatar' => { 'url' => current_user.avatar.url } }
    end

    def provider_params
      if params_with_password?
        params.require(:provider).permit(*PERMITTED_PARAMS)
      else
        params.require(:provider).permit(*PERMITTED_PARAMS_WITHOUT_PASSWORD)
      end
    end

    def params_with_password?
      params.dig(:provider, :suppliers_attributes, :password).present? ||
        params.dig(:provider, :suppliers_attributes, :password_confirmation).present?
    end
  end
end