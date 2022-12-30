require './lib/importers/pb/cooperative_importer'
require './lib/importers/pb/covenant_importer'
require './lib/importers/pb/group_importer'
require './lib/importers/pb/user_importer'

namespace :pb do
  namespace :importers do    
    task cooperative: :environment do |task|
      file = ENV['FILE']

      raise ArgumentError, 'O parâmetro FILE está em branco' unless file.present? && File.file?(file)

      CSV.foreach(file, headers: true, col_sep: '|') do |row|
        resource = {
          cnpj: row['CNPJ'],
          name: row['NOME'],
          address: {
            email: row['EMAIL'],
            phone: row['TELEFONE'] || '-',
            address: row['ENDERECO'],
            city_name: row['CIDADE'],
            state_uf: row['UF'],
            cep: row['CEP'],
            number: row['NUMERO'],
            neighborhood: row['BAIRRO'],
            complement: row['COMPLEMENTO'],
            reference_point: row['PONTO_REFERENCIA'],
            skip_integration_validations: true
          },
          legal_representative: {
            name: row['NOME_REPRESENTANTE'],
            nationality: row['NACIONALIDADE'],
            civil_state: row['ESTADO_CIVIL'],
            rg: row['RG'],
            cpf: row['CPF'],
            address: {
              email: row['EMAIL_REPRESENTANTE'],
              phone: row['TELEFONE_REPRESENTANTE'] || '-',
              address: row['ENDERECO_REPRESENTANTE'],
              city_name: row['CIDADE_REPRESENTANTE'],
              state_uf: row['UF_REPRESENTANTE'],
              cep: row['CEP_REPRESENTANTE'],
              number: row['NUMERO_REPRESENTANTE'],
              neighborhood: row['BAIRRO_REPRESENTANTE'],
              complement: row['COMPLEMENTO_REPRESENTANTE'],
              reference_point: row['PONTO_REFERENCIA_REPRESENTANTE'],
              skip_integration_validations: true
            }
          }
        }

        success, errors = Importers::Pb::CooperativeImporter.call(resource)

        if success == true
          puts "Importado ou atualizado com sucesso!"
        else
          puts errors
        end
      end
    end

    task covenant: :environment do |task|
      file = ENV['FILE']

      raise ArgumentError, 'O parâmetro FILE está em branco' unless file.present? && File.file?(file)

      CSV.foreach(file, headers: true, col_sep: '|') do |row|
        resource = {
          number: row['NUMERO'],
          name: row['NOME'],
          status: row['SITUACAO'],
          signature_date: row['DATA_ASSINATURA'],
          validity_date: row['DATA_VALIDADE'],
          estimated_cost: row['CUSTO_ESTIMADO'],
          city_name: row['CIDADE'],
          state_uf: row['UF'],
          cooperative_cnpj: row['COOPERATIVA_CNPJ'],
          admin: {
            email: row['ADMIN_EMAIL'],
            name: row['ADMIN_NOME'],
            locale: 'pt-BR'
          }
        }

        success, errors = Importers::Pb::CovenantImporter.call(resource)

        if success == true
          puts "Importado ou atualizado com sucesso!"
        else
          puts errors
        end
      end
    end

    task group_item: :environment do |task|
      file = ENV['FILE']

      raise ArgumentError, 'O parâmetro FILE está em branco' unless file.present? && File.file?(file)

      CSV.foreach(file, headers: true, col_sep: '|') do |row|
        resource = {
          covenant_number: row['CONVENIO_NUMERO'],
          group_name: row['GRUPO_NOME'],
          quantity: row['ITEM_QUANTIDADE'],
          estimated_cost: row['ITEM_CUSTO_ESTIMADO'],
          item_attributes: {
            title: row['ITEM_TITULO'],
            classification: row['ITEM_CODIGO_CLASSIFICACAO'],
            unit: row['ITEM_UNIDADE'],
            description: row['ITEM_DESCRICAO'],
            code: row['ITEM_CODIGO']
          },
        }

        success, errors = Importers::Pb::GroupImporter.call(resource)

        if success == true
          puts "Importado ou atualizado com sucesso!"
        else
          puts errors
        end
      end
    end

    task user: :environment do |task|
      file = ENV['FILE']

      raise ArgumentError, 'O parâmetro FILE está em branco' unless file.present? && File.file?(file)

      CSV.foreach(file, headers: true, col_sep: '|') do |row|
        resource = {
          cooperative_cnpj: row['COOPERATIVA_CNPJ'],
          role: row['CARGO'],
          cpf: row['CPF'],
          phone: row['TELEFONE'],
          email: row['EMAIL'],
          name: row['NOME']
        }

        success, errors = Importers::Pb::UserImporter.call(resource)

        if success == true
          puts "Importado ou atualizado com sucesso!"
        else
          puts errors
        end
      end
    end

    # Importador de Fornecedores
    # XXX: O SOL PB solicitou a importação dos dados dos fornecedores
    # do SOL BA, após permissão da equipe da CAR-BA.
    task suppliers: :environment do |task|
      file = ENV['FILE']

      raise ArgumentError, 'O parâmetro FILE está em branco' unless file.present? && File.file?(file)

      def find_city_id(city_id)
        city_id_integer = city_id.to_i

        city_id_integer > 3540 ? city_id_integer + 1 : city_id_integer
      end

      CSV.foreach(file, headers: false, col_sep: '|') do |row|
        @last_imported_provider ||= nil

        if row[0] == "PROVIDER"
          @last_imported_provider = nil

          provider_attributes                     = eval row[1]
          provider_address_attributes             = eval row[2]
          legal_representative_attributes         = eval row[3]
          legal_representative_address_attributes = eval row[4]
          classification_codes                    = row[5].split(',')

          new_provider            = Provider.new
          new_provider.attributes = provider_attributes

          new_provider_address             = Address.new
          new_provider_address.attributes  = provider_address_attributes
          new_provider_address.city_id     = find_city_id(new_provider_address.city_id)
          new_provider_address.addressable = new_provider

          new_provider_address.latitude  = 0 if new_provider_address.latitude.nil?
          new_provider_address.longitude = 0 if new_provider_address.longitude.nil?

          new_legal_representative            = LegalRepresentative.new
          new_legal_representative.attributes = legal_representative_attributes

          new_legal_representative_address             = Address.new
          new_legal_representative_address.attributes  = legal_representative_address_attributes
          new_legal_representative_address.city_id     = find_city_id(new_legal_representative_address.city_id)
          new_legal_representative_address.addressable = new_legal_representative
          
          new_legal_representative_address.latitude  = 0 if new_legal_representative_address.latitude.nil?
          new_legal_representative_address.longitude = 0 if new_legal_representative_address.longitude.nil?

          new_provider.address              = new_provider_address
          new_provider.legal_representative = new_legal_representative
          new_legal_representative.address  = new_legal_representative_address

          classification_codes.each do |classification_code|
            classification = Classification.find_by code: classification_code.to_i

            new_provider.classifications << classification
          end

          if new_provider.save
            @last_imported_provider = new_provider

            puts "Provedor #{new_provider.name} Importado com sucesso!"
          else
            puts "Provider #{new_provider.name} ERRO: #{new_provider.errors.messages}"
          end
        end

        if row[0] == "SUPPLIER"
          supplier_attributes = eval row[1]

          new_supplier = Supplier.new
          new_supplier.attributes             = supplier_attributes
          new_supplier.provider_id            = @last_imported_provider.id
          new_supplier.encrypted_password     = nil
          new_supplier.reset_password_token   = nil
          new_supplier.reset_password_sent_at = nil
          new_supplier.remember_created_at    = nil
          new_supplier.sign_in_count          = 0
          new_supplier.current_sign_in_at     = nil
          new_supplier.last_sign_in_at        = nil
          new_supplier.current_sign_in_ip     = nil
          new_supplier.last_sign_in_ip        = nil
          new_supplier.avatar                 = nil

          new_password = Digest::SHA256.hexdigest new_supplier.email
          new_supplier.password              = new_password 
          new_supplier.password_confirmation = new_password 

          if new_supplier.save
            puts "Fornecedor #{new_supplier.email} importado com sucesso!"
          else
            puts "Supplier #{new_supplier.email} ERRO: #{new_supplier.errors.messages}"
          end
        end
      end
    end
  end
end
