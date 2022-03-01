module Administrator
  class Biddings::RegenerateFailureMinutesController < AdminController
    include CrudController

    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    def update
      if resource.failure?
        Bidding::Minute::PdfRegenerateWorker.perform_async(resource.id)

        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: ['Licitação não está com o status "Fracassada"'] }
      end
    end

    private

    def resource
      bidding
    end
  end
end
