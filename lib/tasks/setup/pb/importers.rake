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
  end
end