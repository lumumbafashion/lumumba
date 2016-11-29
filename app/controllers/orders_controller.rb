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
    prepare_stocks_warning if @order
  end

  def show
    @order = current_user.orders.friendly.find(params[:id])
    prepare_addresses
  end

  def shipping
    address = current_user.addresses.find(params[:id])
    order = current_user.orders.find_by!(status: Order::OPEN)
    order.shipping = address.id
    order.tap(&:calculate_total!).save!
    redirect_back(fallback_location: root_path)
  end

  def checkout
    if the_checkout_order.any_product_out_of_stock?
      flash.now[:error_html_safe] = true
      flash.now[:error] = "Sorry, some of the items in your cart are out of stock now. <b>You have not been charged.</b> Please review your #{view_context.content_tag(:b){ view_context.link_to("cart", orders_path) }} and try again."
      @order = the_checkout_order.reload
      prepare_addresses
      render :show
      return
    end
    if true
      stripe_checkout_impl
    else
      braintree_checkout_impl
    end
  end

  private

  def the_checkout_order
    @the_checkout_order ||= current_user.orders.open.friendly.find(params[:order])
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

  def prepare_stocks_warning
    @order.order_items.group_by(&:product).values.map do |items|
      criterion = items.sum(&:quantity)
      product = items.first.product
      if product.out_of_stock?(criterion)
        flash[:warning] = %|In this cart, you have ordered the product "#{product}" with a quantity greater than our current stock of that product (#{product.stocks.count})|
        return
      end
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

  def prepare_addresses
    @addresses = current_user.addresses
    @address = Address.new
  end

end
