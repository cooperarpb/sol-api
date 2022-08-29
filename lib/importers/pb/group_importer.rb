require './lib/importers/log_importer'
require './lib/importers/pb/item_importer'

module Importers
  module Pb
    class GroupImporter
      include LogImporter

      attr_accessor :resource

      def initialize(resource)
        @resource = resource
      end

      def self.call(resource)
        new(resource).call
      end

      def call
        import_resource
      end

      private

      def import_resource
        @errors = []

        covenant = find_covenant

        import_group(covenant)
      end

      def find_covenant
        @covenant ||= Covenant.find_by(number: resource[:covenant_number])
      end

      def import_group(covenant)
        group = covenant.groups.find_or_initialize_by(name: squish(resource[:group_name]))

        import_group_item(group, resource[:item_attributes])

        save_resource(group)
      end

      def import_group_item(group, item_attributes)
        group_item = group.group_items.find_or_initialize_by(item: find_item(item_attributes))

        unless group_item.new_record?
          group_item.available_quantity = resource[:quantity].to_i - (group_item.quantity - group_item.available_quantity)
        end

        group_item.quantity       = resource[:quantity]
        group_item.estimated_cost = resource[:estimated_cost]

        group_item.save! if group_item.persisted?
      end

      def find_item(attributes)
        item_importer = Importers::Pb::ItemImporter.new(attributes)
        item_importer.call
        item_importer.item
      end

      def squish(attribute)
        (attribute || '').squish
      end

      def save_resource(resource)
        return [true, nil] if resource.save
        
        errorify(resource)
        [false, errors_as_sentence]
      end
    end
  end
end