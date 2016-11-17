require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  describe '#index' do

    context "signed in" do

      sign_as

      context "when I have no orders" do

        before { expect(user.orders.count).to be_zero }

        it "loads correctly" do
          get :index
          controller_ok
        end

      end

      context "when I have one open order" do

        let!(:order) { FactoryGirl.create :order, user: user }

        it "loads correctly" do
          get :index
          controller_ok
        end

      end

      context "when I have two open orders" do

        let!(:order_1) { FactoryGirl.create :order, user: user }
        let!(:order_2) { FactoryGirl.create :order, user: user }

        it "loads correctly" do
          get :index
          controller_ok
        end

      end

    end

    context "signed out" do

      it "is forbidden" do
        get :index
        expect_unauthorized
      end

    end

  end

  describe "#show" do

    def the_action
      get :show, params: {id: order.id}
    end

    context "signed in" do

      sign_as

      [Order::OPEN, SecureRandom.hex].each do |status|

        describe "for the status value '#{status}'" do

          let!(:order){ FactoryGirl.create :order, user: user, status: status }

          context "when I have no addresses" do

            before { expect(user.addresses.count).to be_zero }

            it "loads correctly" do
              the_action
              controller_ok
            end

          end

          context "when I have 1 address" do

            let!(:address){ FactoryGirl.create :address, user: user }

            it "loads correctly" do
              the_action
              controller_ok
            end

          end

          context "when I have 2 addresses" do

            let!(:address_1){ FactoryGirl.create :address, user: user }
            let!(:address_2){ FactoryGirl.create :address, user: user }

            it "loads correctly" do
              the_action
              controller_ok
            end

          end

        end

      end

    end

    context "signed out" do

      let!(:order){ FactoryGirl.create :order }

      it "is forbidden" do
        the_action
        expect_unauthorized
      end

    end

  end

  describe '#shipping' do

    let(:address_params){ {id: address.id} }

    def the_action
      post :shipping, params: address_params
    end

    context "signed in" do

      sign_as

      let!(:address){ FactoryGirl.create :address, user: user }

      context "when I have an open order" do

        let!(:order){ FactoryGirl.create :order, user: user }
        before { expect(user.orders.open.count).to eq 1 }

        it "calculates vat, shipping_cost, shipping (id) and total amount for said order" do

          expect {
            the_action
          }.to change {
            order.reload.vat
          }.and change {
            order.reload.shipping_cost
          }.and change {
            order.reload.shipping
          }.and change {
            order.reload.total_amount
          }

        end

      end

      context "when I have an order, but it's not open" do

        let!(:order){ FactoryGirl.create :order, user: user, status: SecureRandom.hex }
        before { expect(user.orders.open.count).to eq 0 }

        it "returns 404" do
          the_action
          controller_ok 404
        end

        it "doesn't change the order or the address" do
          expect {
            the_action
          }.to_not change {
            [
              order.reload.attributes,
              address.reload.attributes
            ]
          }
        end

      end

      context "when I don't have an order" do

        before { expect(user.orders.open.count).to eq 0 }

        it "returns 404" do
          the_action
          controller_ok 404
        end

        it "changes no address or order" do
          expect {
            the_action
          }.to_not change {
            [
              Order.pluck(:updated_at),
              Address.pluck(:updated_at),
            ]
          }
        end

      end

      context "when try calculate the shipping for order I don't own" do

        let!(:order){ FactoryGirl.create :order }
        before { expect(user.orders.open.count).to eq 0 }
        before { expect(Order.open.count).to eq 1 }

        it "returns 404" do
          the_action
          controller_ok 404
        end

        it "changes no address or order" do
          expect {
            the_action
          }.to_not change {
            [
              Order.pluck(:updated_at),
              Address.pluck(:updated_at),
            ]
          }
        end

      end

    end

    context "signed out" do

      let!(:address){ FactoryGirl.create :address }

      it "is forbidden" do
        the_action
        expect_unauthorized
      end

      it "changes no address or order" do
        expect {
          the_action
        }.to_not change {
          [
            Order.pluck(:updated_at),
            Address.pluck(:updated_at),
          ]
        }
        expect_unauthorized
      end

    end

  end

  describe '#payment' do

    def the_action
      post :payment, params: {id: order.id}
    end

    context "signed in" do

      sign_as

      let!(:address){ FactoryGirl.create :address, user: user }

      describe "when I own an open order, with a shipping address" do

        let!(:order){ FactoryGirl.create :order, user: user, shipping: address.id }
        before { expect(user.orders.open.count).to eq 1 }

        it "loads correctly" do
          expect(Braintree::ClientToken).to receive(:generate).and_return(SecureRandom.hex)
          the_action
          controller_ok
        end

      end

      describe "when I own an open order, with a shipping address, in any status" do

        let!(:order){ FactoryGirl.create :order, user: user, shipping: address.id, status: SecureRandom.hex() }
        before { expect(user.orders.open.count).to eq 0 }
        before { expect(user.orders.count).to eq 1 }

        it "loads correctly" do
          expect(Braintree::ClientToken).to receive(:generate).and_return(SecureRandom.hex)
          the_action
          controller_ok
        end

      end

      describe "when I own an open order, without a shipping address" do

        let!(:order){ FactoryGirl.create :order, user: user }
        before { expect(user.orders.open.count).to eq 1 }

        it "returns 404" do
          the_action
          controller_ok 404
        end

      end

      describe "when I own an open order, without a shipping address, in any status" do

        let!(:order){ FactoryGirl.create :order, user: user, status: SecureRandom.hex() }
        before { expect(user.orders.open.count).to eq 0 }
        before { expect(user.orders.count).to eq 1 }

        it "returns 404" do
          the_action
          controller_ok 404
        end

      end

      describe "attempting to pay an Order I don't own" do

        let!(:order){ FactoryGirl.create :order }

        it "returns 404" do
          the_action
          controller_ok 404
        end

      end

    end

    context "signed out" do

      let!(:order){ FactoryGirl.create :order }

      it "is unauthorized" do
        the_action
        expect_unauthorized
      end

    end

  end

  describe '#checkout' do

    let(:payment_method_nonce){ SecureRandom.hex }
    let(:order_params){
      {
        order: order.id,
        payment_method_nonce: payment_method_nonce
      }
    }

    context "signed in" do

      sign_as

      describe "paying an open order I own" do

        let(:order){ FactoryGirl.create :order, user: user }
        let(:total_amount_formatted){ SecureRandom.hex }
        let(:result){ double }

        let(:transaction_id) { SecureRandom.hex }
        let(:payment_method) { SecureRandom.hex }
        let(:transaction_status) { SecureRandom.hex }
        let(:transaction) do
          double({
            id: transaction_id,
            credit_card_details: double(card_type: payment_method),
            status: transaction_status
          })
        end

        before do
          expect(order).to receive(:total_amount_formatted).and_return(total_amount_formatted)
          expect(controller).to receive(:the_checkout_order).and_return(order)
          expect(Braintree::Transaction).to receive(:sale).with({
            amount: total_amount_formatted,
            payment_method_nonce: payment_method_nonce,
            options: {
              submit_for_settlement: true
            }
          }).and_return(result)
        end

        context "when the Braintree result is a `success?`" do

          before do
            expect(result).to receive(:success?).and_return true
            expect(result).to receive(:transaction).at_least(3).times.and_return transaction
          end

          it "updates the order" do

            expect {
              post :checkout, params: order_params
            }.to change {
              order.reload.transaction_id
            }.to(transaction_id).and change {
              order.reload.payment_method
            }.to(payment_method).and change {
              order.reload.status
            }.to(transaction_status)

          end

        end

        context "when the Braintree result is not a `success?`, but it returns a `transaction`" do

          before do
            expect(result).to receive(:success?).and_return false
            expect(result).to receive(:transaction).at_least(3).times.and_return transaction
          end

          it "updates the order" do

            expect {
              post :checkout, params: order_params
            }.to change {
              order.reload.transaction_id
            }.to(transaction_id).and change {
              order.reload.payment_method
            }.to(payment_method).and change {
              order.reload.status
            }.to(transaction_status)

          end

        end

        context "when the Braintree result is unsuccessful" do

          before do
            expect(result).to receive(:success?).and_return false
            expect(result).to receive(:transaction).and_return false
            expect(result).to receive(:errors).and_return []
          end

          it "doesn't update the order" do
            expect {
              post :checkout, params: order_params
            }.to_not change {
              order.reload.attributes.sort
            }
            controller_ok(302)
          end

          it "redirects to the payment path of the order" do
            post :checkout, params: order_params
            expect(response).to redirect_to(payment_path(order.id))
          end

        end

      end

      describe "attempting to pay an order I own, in an status other than '#{Order::OPEN}'" do

        let(:order){ FactoryGirl.create :order, user: user, status: SecureRandom.hex  }

        it "doesn't update the order" do
          expect {
            post :checkout, params: order_params
          }.to_not change {
            order.reload.attributes.sort
          }
          controller_ok(404)
        end

      end

      describe "attempting to pay an order I don't own" do

        let(:order){ FactoryGirl.create :order }

        it "doesn't update the order" do
          expect {
            post :checkout, params: order_params
          }.to_not change {
            order.reload.attributes.sort
          }
          controller_ok(404)
        end

      end

    end

    context "signed out" do

      describe "attempting make pay any order" do

        let(:order){ FactoryGirl.create :order }

        it "doesn't update the order" do
          expect {
            post :checkout, params: order_params
          }.to_not change {
            order.reload.attributes.sort
          }
          expect_unauthorized
        end

      end

    end

  end

end
