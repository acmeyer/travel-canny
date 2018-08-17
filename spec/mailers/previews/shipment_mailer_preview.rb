# Preview all emails at http://localhost:3000/rails/mailers/shipment_mailer
class ShipmentMailerPreview < ActionMailer::Preview
  def shipment_shipped
    ShipmentMailer.shipment_shipped(Shipment.last.id)
  end
end
