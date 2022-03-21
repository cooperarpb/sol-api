module Coop
  class ClassificationsController < CoopController
    def index
      render json: sorted_classifications, each_serializer: ClassificationSerializer
    end

    private

    def parent_classification_param_id
      params[:parent_classification_id]
    end

    def classifications
      return Classification.parent_classifications unless parent_classification_param_id.present?

      Classification.where(classification: parent_classification_param_id.to_i)
    end

    def sorted_classifications
      classifications.sorted
    end
  end
end
