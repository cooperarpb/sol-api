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
      comment: bidding_failure_service_comment
    }
  end

  # XXX: O comentário final será o compilado dos motivos das recusas de cada proposta
  # por parte da associação
  def bidding_failure_service_comment
    Events::ProposalStatusChange
      .where(eventable: bidding.proposals.refused)
      .map(&:comment)
      .join('. ')
  end
end