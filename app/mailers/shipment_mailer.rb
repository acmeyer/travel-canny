class ShipmentMailer < ApplicationMailer

  def shipment_shipped(shipment_id)
    @shipment = Shipment.find(shipment_id)
    @sim = @shipment.sim
    @user = @sim.user
    mail(to: @user.email, subject: 'A shipment is coming your way!')
  end
end
