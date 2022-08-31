require './lib/importers/log_importer'

module Importers
  module Pb
    class UserImporter
      include LogImporter

      attr_accessor :resource

      def initialize(resource)
        @resource = resource
      end

      def self.call(resource)
        new(resource).call
      end

      def call
        import_resource
      end

      private

      def import_resource
        @errors = []

        user = cooperative.users.find_or_initialize_by(cpf: cpf_mask)

        user.attributes = user_attributes(resource)

        user.skip_password_validation!
        user.skip_integration_validations!

        save_resource(user)
      end

      def cpf_mask
        @cpf_mask ||= CPF.mask(squish(resource[:cpf]))
      end

      def cooperative
        cnpjs = [cooperative_cnpj, maskCnpj(cooperative_cnpj)]
        @cooperative ||= Cooperative.find_by(cnpj: cnpjs)
      end

      def cooperative_cnpj
        squish(resource[:cooperative_cnpj])
      end

      def user_attributes(attributes)
        return {} unless attributes.present?
  
        attributes[:cooperative_id] = cooperative.id 
        attributes[:role_id] = find_role(attributes[:role])&.id if attributes[:role].present?
        attributes[:phone] = PhoneNumber.mask(squish(attributes[:phone]))
        attributes.except(:role, :cpf, :cooperative_cnpj)
      end

      def find_role(role)
        role_title = squish(role)
        role = Role.search(role_title).first
        return role if role
  
        Role.create(title: role_title)
      end

      def maskCnpj(number)
        CNPJ.mask(number)
      end

      def squish(attribute)
        (attribute || '').squish
      end

      def save_resource(resource_model)
        return [true, nil] if resource_model.save
        
        errorify(resource_model)
        [false, errors_as_sentence]
      end

      def resource_klass
        'user'
      end
  
      def log_header_title
        cpf_mask
      end
    end
  end
end