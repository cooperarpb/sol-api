#
# Métodos e constantes de busca para Estados
#

module State::Search
 extend ActiveSupport::Concern
 include Searchable

 SEARCH_EXPRESSION = %q{
   unaccent(LOWER(cities.name)) LIKE unaccent(LOWER(:search))
 }
end