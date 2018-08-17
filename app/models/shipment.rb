class Shipment < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  belongs_to :sim, touch: true

  validates :status, presence: true
  validates :tracking_link, presence: true, if: :has_shipped

  enum status: [ :processing, :shipped, :received ]

  before_validation :add_status, if: :status_empty
  after_update :send_shipment_notification

  scope :pending, -> { where(status: :processing) }

  include PgSearch
  pg_search_scope :search_shipments, :against => [:status, :tracking_number, :carrier]

  accepts_nested_attributes_for :address, allow_destroy: true

  private
  def has_shipped
    status == 'shipped'
  end

  def status_empty
    self.status.blank?
  end

  def add_status
    self.status = 'processing'
  end

  def send_shipment_notification
    # TODO: make it better to only send if it is changing from processing to shipped
    ShipmentMailer.shipment_shipped(self.id).deliver_later if (self.saved_change_to_status? && self.status == 'shipped')
  end
end
