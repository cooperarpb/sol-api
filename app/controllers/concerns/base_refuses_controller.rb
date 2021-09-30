module BaseRefusesController
  extend ActiveSupport::Concern

  def update
    if render_status
      render status: :ok
    else
      render status: :unprocessable_entity
    end
  end

  private

  # XXX: Adicionar serviço que irá tentar aprovar a recusa da proposta pela associação
  def refused?; end

  def bidding; end

  # XXX: Caso o revisor aprovar a recusa da proposta e todas os lotes da licitaçãi estiverem fracassados, 
  # chamas-se o serviço `bidding_failure_service` para fracassar a licitação de forma automática. 
  # Caso contrário, retorna o status da aprovação da recusa da proposta.
  def render_status
    refused_status = refused?
    (refused_status && bidding_fully_refused_proposals?) ? !!bidding_failure_service : refused_status
  end

  def bidding_fully_refused_proposals?
    bidding.fully_refused_proposals?
  end

  def bidding_failure_service
    BiddingsService::Failure.call(failure_service_attributes)
  end

  def failure_service_attributes
    {
      bidding: bidding,
      creator: current_user,
      comment: I18n.t('services.biddings.system_bidding_failure.comment')
    }
  end
end