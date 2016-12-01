class Order < ApplicationRecord

  OPEN = 'open'
  SUCCESSFULLY_PAID = 'successfully_paid'
  STRIPE_EUR = 'eur'
  DEFAULT_SHIPPING_COST = 15.0
  DEFAULT_VAT_COST = 0.0

  extend FriendlyId
  friendly_id :order_number, use: :slugged

  belongs_to :user
  has_many :order_items
  has_many :products, through: :order_items

  validates :user, presence: true
  validates :order_number, presence: true
  validates :total_amount, presence: true, if: :successfully_paid?
  validates :status, presence: true, inclusion: [OPEN, SUCCESSFULLY_PAID]
  validates :transaction_id, presence: true, if: :successfully_paid?
  if false
    validates :payment_method, presence: true, if: :successfully_paid?
  end

  after_initialize :set_default_values
  after_commit :send_confirmation_email

  def set_default_values
    # Only set if total_amount and/or order_number IS NOT set
    self.order_number ||= SecureRandom.base58(24)
  end

  def self.open
    where(status: OPEN)
  end

  def address
    Address.find_by_id(self.shipping)
  end

  def self.charge_description_for order
    "Lumumba - order id ##{order.id}"
  end

  def description
    self.class.charge_description_for self
  end

  def open?
    self.status == OPEN
  end

  def successfully_paid?
    self.status == SUCCESSFULLY_PAID
  end

  def total_amount_formatted
    total_amount.round(2).to_s
  end

  def total_amount_in_cents
    (total_amount * 100.0).round
  end

  def charged?
    transaction_id.present?
  end

  # note that there can exist N OrderItems referring to the same product, hence the slightly complicated method
  def any_product_out_of_stock?
    order_items.group_by(&:product).values.any? do |items|
      criterion = items.sum(&:quantity)
      items.first.product.out_of_stock?(criterion)
    end
  end

  def safely_delete_stocks!
    begin
      order_items.group_by(&:product).values.map do |items|
        product = items.first.product
        criterion = items.sum(&:quantity)
        stocks = Stock.where(product: product).limit(criterion)
        if stocks.count < criterion
          SafeLogger.error { "Expected #{criterion} Stock records from product #{product} to exist, only #{stocks.count} exist" }
        end
        stocks.map(&:destroy!)
      end
    rescue => e
      SafeLogger.error { "#{e.class} in `Order#safely_delete_stocks!`: #{e}" }
    end
  end

  def charge!(token)

    raise "already charged" if charged?

    charge = nil

    charge = Stripe::Charge.create(
      amount: total_amount_in_cents,
      currency: STRIPE_EUR,
      source: token,
      description: description
    )

    Rails.logger.info "Successfully charged order with id #{id}. Charge id: #{charge.id}"

    self.transaction_id = charge.id
    self.status = SUCCESSFULLY_PAID
    saved = self.save
    unless saved
      message = "Stripe charge succeeded, but could not update the order with id #{self.id}. Errors: #{self.errors.full_messages}"
      Rails.logger.error message
      Rollbar.error message
    end

    safely_delete_stocks!

    return true

  rescue Stripe::CardError => e
    Rails.logger.error e.class
    Rails.logger.error e
    Rollbar.error e
    return false
  end

  def send_confirmation_email
    if successfully_paid?
      change = previous_changes[:status]
      if change && (change[1] == SUCCESSFULLY_PAID)
        UserMailer.purchase_confirmation(self).deliver_now
      end
    end
  end

  def find_tax
    Tax.find_by(country: self.address.try(:country))
  end

  def calculate_shipping!
    tax = find_tax
    self.shipping_cost = tax && ((tax.country == Tax::ES) ? 5.0 : 10.0) || DEFAULT_SHIPPING_COST
  end

  def calculate_vat!
    tax = find_tax
    self.vat = tax && (tax.vat_rate * self.sub_total) || DEFAULT_VAT_COST
  end
  
  def calculate_total!
    calculate_shipping!
    calculate_vat!
    self.total_amount = self.sub_total + self.shipping_cost + self.vat
  end
  
end
