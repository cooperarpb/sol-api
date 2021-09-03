class Contract < ApplicationRecord
  include ::Sortable
  include ::Contract::Search

  SUPPLIER_SIGNATURE_DEADLINE = 5.freeze

  versionable ignore: %i[deleted_at]

  default_scope { where(deleted_at: nil) }

  after_create :update_title

  belongs_to :proposal
  belongs_to :supplier, optional: proc { |obj| !obj.supplier_signed_at? }
  belongs_to :user
  belongs_to :refused_by, polymorphic: true, optional: true
  belongs_to :document, optional: true

  has_one :bidding, through: :proposal
  has_one :classification, through: :bidding, source: :classification

  has_many :returned_lot_group_items, dependent: :destroy
  has_many :lot_group_item_lot_proposals, through: :proposal
  has_many :lot_group_items, through: :lot_group_item_lot_proposals
  has_many :lot_group_items_returned, through: :returned_lot_group_items, source: :lot_group_item

  has_many :event_contract_refuseds,
           class_name: 'Events::ContractRefused', foreign_key: :eventable_id,
           dependent: :destroy

  delegate :price_total, to: :proposal, prefix: true

  enum status: {
    waiting_signature: 0, signed: 1, completed: 2,
    partial_execution: 3, total_inexecution: 4, refused: 5, unsigned_by_supplier: 6
  }

  validates :supplier_signed_at, presence: true, if: proc { |obj| obj.supplier_id? }
  validates :deadline, presence: true

  accepts_nested_attributes_for :returned_lot_group_items

  # scopes
  scope :waiting_signature_and_old, -> do
    waiting_signature.
      where("created_at < ?", 5.days.ago).
      where(supplier: nil).
      where.not(proposal: nil)
  end

  scope :by_provider, -> (provider_id) do
    joins(:proposal).where(proposals: { provider_id: provider_id })
  end

  scope :returned_items_by, -> (lot_group_item_id) do
    joins(:returned_lot_group_items).
      where(returned_lot_group_items: { lot_group_item_id: lot_group_item_id })
  end

  # XXX: Esse escopo é utilizado para verificar o status do contrato para o envio de notificações
  # aos fornecedores que não assinaram o contrato dentro do prazo estipulado pela constante SUPPLIER_SIGNATURE_DEADLINE (5 dias).
  # Como as notificações são disparadas de madrugada, a notificação do penúltimo dia é enviada após 3 dias,
  # dando ao fornecedor tempo para assinar ao longo do quarto dia.
  # Obs.: Conta-se a partir da criação do contrato.
  scope :close_to_supplier_signature_deadline, -> do
    waiting_signature
      .where(supplier: nil)
      .where('DATE(created_at) = ?', (SUPPLIER_SIGNATURE_DEADLINE - 2).days.ago)
  end

  # XXX: Esse escopo é utilizado para verificar o status do contrato para o envio de notificações
  # aos fornecedores que não assinaram o contrato dentro do prazo estipulado pela constante SUPPLIER_SIGNATURE_DEADLINE (5 dias).
  # Como as notificações são disparadas de madrugada, a notificação do último dia é enviada após 4 dias,
  # dando ao fornecedor tempo para assinar ao longo do último dia. 
  # Obs.: Conta-se a partir da criação do contrato.
  scope :last_day_of_supplier_signature_deadline, -> do
    waiting_signature
      .where(supplier: nil)
      .where('DATE(created_at) = ?', (SUPPLIER_SIGNATURE_DEADLINE - 1).days.ago)
  end

  # XXX: Esse escopo é utilizado para verificar o status do contrato para o envio de notificações
  # aos fornecedores que não assinaram o contrato dentro do prazo estipulado pela constante SUPPLIER_SIGNATURE_DEADLINE (5 dias).
  # Como as notificações são disparadas de madrugada, a verificação dos contratos expirados é realizada após 5 dias da 
  # criação do contrato.
  # Obs.: Conta-se a partir da criação do contrato.
  scope :expired_supplier_signature_deadline, -> do
    waiting_signature
      .where(supplier: nil)
      .where('DATE(created_at) = ?', SUPPLIER_SIGNATURE_DEADLINE.days.ago)
  end

  def self.not_refused
    where.not(status: :refused)
  end

  def self.by_classification(classification_id)
    joins(:classification, :proposal).where(
      classifications: { id: classification_id },
      proposals: { status: :accepted }
    )
  end

  def price_by_proposal_accepted
    self.class.joins(:proposal).where(proposals: { status: :accepted }).where(id: self.id).sum('proposals.price_total')
  end

  # sortable
  def self.default_sort_column
    'contracts.id'
  end

  def self.default_sort_direction
    :desc
  end

  def all_signed?
    supplier.present? && user.present?
  end

  def refused_by!(user_refused)
    self.refused_by = user_refused
    self.refused_by_at = DateTime.current
    self.refused!
  end

  def refused_by_type_supplier?
    refused_by_type == 'Supplier'
  end

  def refused_by_type_system?
    refused_by_type == 'System'
  end

  def classification_name
    classification.name
  end

  private

  def update_title
    update_column(:title, "#{id}/#{created_at.year}")
  end

end
