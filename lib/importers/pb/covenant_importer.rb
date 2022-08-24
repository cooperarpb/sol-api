require './lib/importers/log_importer'

module Importers
  module Pb
    class CovenantImporter
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


      def import_resource
        @errors = []

        return unless resource.present?

        import_covenant

        save_resource(@covenant)
      end

      def import_covenant
        @covenant = Covenant.find_or_initialize_by(number: covenant_number)
        @covenant.attributes = covenant_attributes

        @covenant.admin = admin
        @covenant.cooperative = cooperative
        @covenant.city = city
      end

      def save_resource(resource, params={})
        return [true, nil] if resource.save
        
        errorify(resource, { skip_errors: :users })
        [false, errors_as_sentence]
      end


      def covenant_attributes
        {
          name: resource[:name],
          status: covenant_status_enum,
          signature_date: resource[:signature_date],
          validity_date: resource[:validity_date],
          estimated_cost: resource[:estimated_cost]
        }
      end

      def covenant_status_enum
        status = resource[:status]

        return :waiting   if status&.downcase == "espera"
        return :running   if status&.downcase == "andamento"
        return :completed if status&.downcase == "completado"
        return :canceled  if status&.downcase == "cancelado"
      end

      def admin
        admin_hash = resource.fetch(:admin, {})

        admin = Admin.find_or_initialize_by(email: squish(admin_hash[:email]))
        admin.name = squish(admin_hash[:name])

        # existing admins can be general and be assigned to covenants
        # without losing its role
        admin.role = :reviewer unless admin.persisted?

        admin.skip_password_validation!
        admin.save

        admin
      end

      def cooperative
        cnpjs = [cooperative_cnpj, maskCnpj(cooperative_cnpj)]
        @cooperative ||= Cooperative.find_by(cnpj: cnpjs)
      end

      def cooperative_cnpj
        squish(resource[:cooperative_cnpj])
      end

      def city
        City.includes(:state)
            .find_by(name: resource[:city_name], states: { uf: resource[:state_uf] })
      end

      def maskCnpj(number)
        CNPJ.mask(number)
      end

      def covenant_number
        squish(resource[:number])
      end

      def squish(attribute)
        (attribute || '').squish
      end

      def resource_klass
        'covenant'
      end

      def log_header_title
        covenant_number
      end
    end
  end
end