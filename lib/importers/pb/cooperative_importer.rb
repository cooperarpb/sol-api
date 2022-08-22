require './lib/importers/log_importer'


# Importers::Pb::CooperativeImporter
# 
# Class responsável pela importação dos dados de uma cooperativa.
# 
# Uma cooperativa possui a seguinte estrutura no banco de dados:
# - name:string
# - cnpj:string
# - has_one :legal_representative
#   - representable_type:string
#   - representable_id:bigint
#   - name:string
#   - nationality:string
#   - civil_state:string
#   - rg:string
#   - cpf:string
#   - valid_until:date
# - has_one :address
#   - addressable_type:string
#   - addressable_id:bigint
#   - latitude:decimal
#   - longitude:decimal
#   - address:string
#   - number:string
#   - neighborhood:string
#   - cep:string
#   - complement:string
#   - reference_point:string
#   - city_id:bigint
#   - phone:string
#   - email:string
# 
# O importador recebe uma Hash contendo os dados de uma cooperativa.
# 
module Importers
  module Pb
    class CooperativeImporter
      include LogImporter

      attr_accessor :cooperative_hash

      def initialize(cooperative_hash)
        @cooperative_hash = cooperative_hash
      end

      def self.call(cooperative_hash)
        new(cooperative_hash).call
      end

      def call
        import
      end

      private

      def import
        @errors = []

        return unless cooperative_hash.present?

        import_cooperative
        import_address
        import_legal_representative

        save_resource(@cooperative)
      end

      def import_cooperative
        @cooperative      = Cooperative.find_or_initialize_by(cnpj: cooperative_cnpj)
        @cooperative.name = squish(cooperative_hash[:name])
      end

      def import_address
        address            = @cooperative.address || @cooperative.build_address
        address.attributes = address_attributes(cooperative_hash[:address])
        address.skip_integration_validations!
  
        save_resource(address) if address.persisted?
  
        errorify(address)
      end

      def import_legal_representative
        legal_representative            = @cooperative.legal_representative || @cooperative.build_legal_representative
        legal_representative.attributes = legal_representative_attributes
  
        errorify(legal_representative)
  
        legal_representative_address = legal_representative.address || legal_representative.build_address
        legal_representative_address.skip_integration_validations!
        legal_representative_address.attributes = address_attributes(cooperative_hash.dig(:legal_representative, :address))
  
        save_resource(legal_representative_address) if legal_representative_address.persisted?
  
        errorify(legal_representative_address)
      end

      def address_attributes(attributes)
        return {} unless attributes.present?
  
        attributes[:city_id] = find_city(city_name: attributes[:city_name], state_uf: attributes[:state_uf])&.id
        attributes[:cep] = mask_cep(attributes[:cep])
        attributes.except(:city, :state_uf, :city_name)
      end

      def legal_representative_attributes
        attributes = cooperative_hash.fetch(:legal_representative, {})
        cpf = CPF.mask(squish(attributes[:cpf]))
  
        attributes.except(:address).merge(civil_state: civil_state_enum, cpf: cpf)
      end

      def save_resource(resource, params={})
        return [true, nil] if resource.save
        
        errorify(resource, { skip_errors: :users })
        [false, errors_as_sentence]
      end

      def civil_state_enum
        civil_state = squish(cooperative_hash.dig(:legal_representative, :civil_state) || '')
  
        case civil_state[0..2].upcase
        when "SOL" then :single
        when "CAS" then :married
        when "DIV" then :divorced
        when "VIU" then :widower
        when "SEP" then :separated
        else :single
        end
      end

      def resource_klass
        'cooperative'
      end
  
      def log_header_title
        cooperative_cnpj
      end

      def mask_cep(cep)
        ZipCode.mask(cep)
      end 

      def mask_cnpj(number)
        CNPJ.mask(number)
      end

      def squish(attribute)
        (attribute || '').squish
      end

      def find_city(**args)
        City.includes(:state)
            .find_by(name: args[:city_name], states: { uf: args[:state_uf] })
      end

      def cooperative_cnpj
        @cooperative_cnpj ||= mask_cnpj(squish(cooperative_hash[:cnpj]))
      end
    end
  end
end