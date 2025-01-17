class AddressSerializer < ActiveModel::Serializer

  attributes :id, :latitude, :longitude, :city_name, :city_id, :address, :number,
               :neighborhood, :cep, :complement, :reference_point, :phone, :email,
               :state_id

  belongs_to :city

  def latitude
    object.latitude.to_s
  end

  def longitude
    object.longitude.to_s
  end

  def city_name
    object.city_name
  end

  def state_id
    object.city&.state_id
  end
end
