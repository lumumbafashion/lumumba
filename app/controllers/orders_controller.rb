require 'rubygems'
require 'braintree' if false

class OrdersController < ApplicationController

  if false
    Braintree::Configuration.environment = :sandbox
    Braintree::Configuration.merchant_id = ENV['BRAINTREE_MERCHANT_ID']
    Braintree::Configuration.public_key = ENV['BRAINTREE_PUBLIC_KEY']
    Braintree::Configuration.private_key = ENV['BRAINTREE_PRIVATE_KEY']
  end

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def index
    @order = current_user.orders.open.first
  end

  def show
    @order = current_user.orders.friendly.find(params[:id])
    @addresses = current_user.addresses
    @address = Address.new
  end

  def shipping
    address = current_user.addresses.find(params[:id])
    order = current_user.orders.find_by!(status: Order::OPEN)
    tax = calculate_tax(address, order)
    shipping_cost = calculate_shipping(address)
    save_order(order, tax, shipping_cost, address)
    redirect_back(fallback_location: root_path)
  end

  def checkout
    if true
      stripe_checkout_impl
    else
      braintree_checkout_impl
    end
  end

  private

  def calculate_tax(address, order)
    country = Tax.find_by country: address.country
    tax_rate = 0.0
    unless country.nil?
      rate = country.vat_rate
      tax_rate = rate * order.sub_total
    end
    tax_rate
  end

  def calculate_shipping(address)
    shipping_cost = 15.00
    if tax = Tax.find_by(country: address.country)
      shipping_cost = if tax.country == Tax::ES
                        5.0
                      else
                        10.0
                      end
    end
    shipping_cost
  end

  def save_order(order, tax, shipping_cost, address)
    order.vat = tax
    order.shipping_cost = shipping_cost
    order.shipping = address.id.to_i
    order.total_amount = order.sub_total + order.shipping_cost + order.vat
    order.save!
  end

  def the_checkout_order
    current_user.orders.open.friendly.find(params[:order])
  end

  def get_generated_token
    if Rails.env.development?
      SecureRandom.hex
    else
      Braintree::ClientToken.generate
    end
  end

  def stripe_checkout_impl
    order = the_checkout_order
    stripe_token = params.require :stripe_token
    if order.charge! stripe_token
      # Do nothing in particular. Just render view
    else
      order.reload # for cleaning up any possibly modified attributes
      flash[:error] = 'Sorry, there has been a problem with your payment. You have not been charged.'
      redirect_to order_path(params['order'])
    end
  end

  def braintree_checkout_impl
    order = the_checkout_order
    nonce = params[:payment_method_nonce]

    result = Braintree::Transaction.sale(
      amount: order.total_amount_formatted,
      payment_method_nonce: nonce,
      options: {
        submit_for_settlement: true
      }
    )

    if result.success? || result.transaction
      order.transaction_id = result.transaction.id
      order.payment_method = result.transaction.credit_card_details.card_type
      order.status = result.transaction.status
      order.save!
    else
      user_error_messages = result.errors.map { |error| "Error: #{error.code}: #{error.message}" }
      internal_error_message = user_error_messages.join('; ')
      Rollbar.warn internal_error_message
      Rails.logger.warn internal_error_message
      flash[:error] = user_error_messages
      redirect_to order_path(params['order'])
    end
  end

end
