module Administrator
  class Biddings::RegenerateMinutesController < AdminController
    include CrudController

    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    def update
      if valid_bidding_statuses?
        Bidding::Minute::PdfRegenerateWorker.perform_async(resource.id)

        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: ['Licitação não está com o status válido: "Fracassada" ou "Deserta" ou "Concluída"'] }
      end
    end

    private

    def resource
      bidding
    end

    def valid_bidding_statuses?
      resource.failure? || 
      resource.desert?  || 
      resource.finnished?
    end
  end
end
