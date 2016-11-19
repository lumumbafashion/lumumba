require 'rails_helper'

RSpec.describe OrderItemsController, type: :controller do

  describe '#create' do

    let!(:product) { FactoryGirl.create :product }
    let(:reference_order_item) { FactoryGirl.build :order_item }
    let(:order_item_params) {
      {
        product_id: product.id,
        order_item: {
          quantity: reference_order_item.quantity,
          size: reference_order_item.size
        }
      }
    }

    def the_action
      post :create, params: order_item_params
    end

    context "signed in" do

      sign_as

      shared_examples "creates_one_order_item" do

        it "results in an OrderItem being created" do
          expect {
            the_action
          }.to change {
            OrderItem.count
          }.by(1)

          oi = OrderItem.last

          expect(oi.quantity).to eq(reference_order_item.quantity)
          expect(oi.size).to eq(reference_order_item.size)

        end

      end

      context "when the user had no open orders" do

        before do
          expect(user.orders.count).to be_zero
        end

        include_examples "creates_one_order_item"

        it "results in an open order being created for that user, having exacty one item" do
          expect {
            the_action
          }.to change {
            user.reload.orders.count
          }.from(0).to(1)
          order = Order.last
          expect(order.status).to eq Order::OPEN
          expect(order.user).to eq user
          expect(order.order_items.count).to eq 1
        end

      end

      context "when the user had an existing open order already" do

        let!(:order){ FactoryGirl.create :order, user: user }

        before do
          expect(user.orders.count).to eq 1
        end

        context "when said order had 0 items" do

          before do
            expect(order.order_items.count).to eq 0
          end

          include_examples "creates_one_order_item"

          it "doesn't result in a new Order being created" do
            expect {
              the_action
            }.to_not change {
              user.reload.orders.count
            }
          end

          it "doesn't result the order status being changed" do
            expect {
              the_action
            }.to_not change {
              order.reload.status
            }
          end

          it "adds one OrderItem to the existing Order" do
            expect {
              the_action
            }.to change {
              order.reload.order_items.count
            }.from(0).to(1)
          end

        end

        context "when said order had 1 item" do

          let!(:order_item){ FactoryGirl.create :order_item, order: order }

          before do
            expect(order.order_items.count).to eq 1
          end

          include_examples "creates_one_order_item"

          it "doesn't result in a new Order being created" do
            expect {
              the_action
            }.to_not change {
              user.reload.orders.count
            }
          end

          it "doesn't result the order status being changed" do
            expect {
              the_action
            }.to_not change {
              order.reload.status
            }
          end

          it "adds one OrderItem to the existing Order" do
            expect {
              the_action
            }.to change {
              order.reload.order_items.count
            }.from(1).to(2)
          end

        end

        context "when said order had 2 items" do

          let!(:order_item_1){ FactoryGirl.create :order_item, order: order }
          let!(:order_item_2){ FactoryGirl.create :order_item, order: order }

          before do
            expect(order.order_items.count).to eq 2
          end

          include_examples "creates_one_order_item"

          it "doesn't result in a new Order being created" do
            expect {
              the_action
            }.to_not change {
              user.reload.orders.count
            }
          end

          it "doesn't result the order status being changed" do
            expect {
              the_action
            }.to_not change {
              order.reload.status
            }
          end

          it "adds one OrderItem to the existing Order" do
            expect {
              the_action
            }.to change {
              order.reload.order_items.count
            }.from(2).to(3)
          end

        end

      end

    end

    context "signed out" do

      it "doesn't result in an Order being created" do
        expect {
          the_action
        }.to_not change {
          Order.count
        }
      end

      it "doesn't result in an OrderItem being created" do
        expect {
          the_action
        }.to_not change {
          OrderItem.count
        }
      end

      it "is unauthorized" do
        the_action
        expect_unauthorized
      end

    end

  end

  describe '#destroy' do

    let!(:product){ FactoryGirl.create :product }
    let!(:delete_params){ {product_id: product.id, id: order_item.id} }

    def the_action
      delete :destroy, params: delete_params
    end

    context "signed in" do

      sign_as

      context "when I own an order with status 'open'" do

        let!(:order){ FactoryGirl.create :order, user: user }

        before { expect(order.status).to eq(Order::OPEN) }

        context "and said order has one orderitem" do

          let!(:order_item){ FactoryGirl.create :order_item, order: order }

          it "is possible to delete the orderitem" do
            expect {
              the_action
            }.to change {
              OrderItem.find_by_id(order_item.id).present?
            }.from(true).to(false)
          end

          it "doesn't delete the Order" do
            expect {
              the_action
            }.to_not change {
              Order.find_by_id(order.id).present?
            }
          end

        end

      end

      context "when I own an order with status other than 'open'" do

        let!(:order){ FactoryGirl.create :order, user: user, status: SecureRandom.hex }

        before { expect(order.status).to_not eq(Order::OPEN) }

        context "and said order has one orderitem" do

          let!(:order_item){ FactoryGirl.create :order_item, order: order }

          it "is possible to delete the orderitem" do

            expect {
              the_action
            }.to_not change {
              Order.find(order.id) # note that find would throw an exception if the deletion was performed.
            }

          end

        end
      end

      describe "attempting to delete an orderitem which order I don't own" do



      end

    end

    context "signed out" do

      let!(:order_item){ FactoryGirl.create :order_item }

      before { expect(order_item.order.id).to be_present }

      it "is forbidden: it doesn't delete any OrderItem" do
        expect {
          the_action
        }.to_not change {
          OrderItem.count
        }
      end

      it "is forbidden: it doesn't delete any Order" do
        expect {
          the_action
        }.to_not change {
          Order.count
        }
      end

    end

  end

end
