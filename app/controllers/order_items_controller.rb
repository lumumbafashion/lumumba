class OrderItemsController < ApplicationController

  before_action :authenticate_user!
  after_action :expire_user_order_item_count_cache!

  def create

    item = OrderItem.new(order_item_params)
    order = current_user.orders.open.first || current_user.orders.new(status: Order::OPEN)
    amount = the_product.price * item.quantity

    save_item_and_order(item, order, amount)

    redirect_back(fallback_location: root_path)

  end

  def destroy
    order_item = OrderItem.find(params[:id])
    if order_item.order.user_id.present? && (current_user.id == order_item.order.user_id)
      success = false
      begin
        success = order_item.remove_from_cart!
      rescue
        success = false
      end
      if success
        flash['success'] = 'Item successfully deleted from Cart.'
      else
        flash['error'] = 'Sorry, we encountered an error while deleting the item from the Cart.'
      end
    else
      flash[:warning] = 'You do not have the permission to delete this item.'
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def save_item_and_order(item, order, amount)
    item.order = order
    item.product = the_product
    order.sub_total += amount

    begin
      ActiveRecord::Base.transaction do
        item.save!
        order.save!
      end
      flash[:success_html_safe] = true
      flash[:success] = "Item successfully added to #{view_context.content_tag(:b){ view_context.link_to("Cart", orders_path) }}."
    rescue => e
      Rollbar.warn e
      Rails.logger.warn e
      if item.size.blank?
        flash[:warning] = 'Please select a size for your clothing purchase!'
      else
        flash['error'] = 'The item could not be added to your cart. Please try again!'
      end
    end
  end

  def order_item_params
    params.require(:order_item).permit(:quantity, :size)
  end

  def the_product
    @the_product ||= Product.friendly.find(params[:product_id])
  end

end
