class State < ApplicationRecord
  include City::Search
  include ::Sortable

  has_many :cities, dependent: :destroy

  validates :name,
            :uf,
            :code,
            presence: true

  validates_uniqueness_of :name, case_sensitive: false
  validates_uniqueness_of :uf, case_sensitive: false
  validates_uniqueness_of :code

  def self.default_sort_column
    'states.name'
  end
  
  def text
    name
  end
end