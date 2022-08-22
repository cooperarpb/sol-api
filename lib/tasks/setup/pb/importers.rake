require './lib/importers/pb/cooperative_importer'

namespace :pb do
  namespace :importers do
    desc ''
    
    task cooperative: :environment do |task|
      file = ENV['FILE']

      raise ArgumentError, 'O parâmetro FILE está em branco' unless file.present? && File.file?(file)

      CSV.foreach(file, headers: true, col_sep: '|') do |row|
        resource = {
          cnpj: row['CNPJ'],
          name: row['NOME'],
          address: {
            email: row['EMAIL'],
            phone: row['TELEFONE'],
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
              phone: row['TELEFONE_REPRESENTANTE'],
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
  end
end