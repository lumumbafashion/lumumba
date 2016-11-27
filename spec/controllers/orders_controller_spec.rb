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

      describe "for the status value '#{Order::OPEN}'" do

        let!(:order){ FactoryGirl.create :order, user: user, status: Order::OPEN }

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

      describe "for the status value '#{Order::SUCCESSFULLY_PAID}'" do

        let!(:order){ FactoryGirl.create :order, :successfully_paid, user: user }

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

      context "when I have a paid order" do

        let!(:order){ FactoryGirl.create :order, :successfully_paid, user: user }
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

  describe '#checkout' do

    let(:payment_method_nonce){ SecureRandom.hex }
    let(:order_params){
      {
        order: order.id,
        stripe_token: payment_method_nonce
      }
    }

    context "signed in" do

      sign_as

      describe "paying an open order I own" do

        let(:order){ FactoryGirl.create :order, user: user }
        let(:total_amount_in_cents){ order.total_amount_in_cents }
        let(:description){ order.description }
        let(:result){ double }

        let(:transaction_id) { SecureRandom.hex }
        let(:payment_method) { SecureRandom.hex }
        let(:transaction_status) { Order::SUCCESSFULLY_PAID }
        let(:transaction) do
          double({
            id: transaction_id,
            credit_card_details: double(card_type: payment_method),
            status: transaction_status
          })
        end

        before do
          expect(controller).to receive(:the_checkout_order).at_least(1).times.and_return(order)
        end

        describe "Stripe success" do

          before do
            expect(Stripe::Charge).to receive(:create).with({
              amount: total_amount_in_cents,
              currency: Order::STRIPE_EUR,
              source: payment_method_nonce,
              description: description
            }).and_return(result)
          end

          before do
            expect(result).to receive(:id).at_least(1).times.and_return transaction_id
          end

          it "updates the order" do

            expect {
              post :checkout, params: order_params
            }.to change {
              order.reload.transaction_id
            }.to(transaction_id).and change {
              order.reload.status
            }.to(transaction_status)

          end

          it "results in a confirmation email being sent" do
            expect(UserMailer).to receive(:purchase_confirmation).with(order).and_call_original
            post :checkout, params: order_params
          end

        end

        context "when the Stripe result is unsuccessful" do

          before do
            expect(Stripe::Charge).to receive(:create).with({
              amount: total_amount_in_cents,
              currency: Order::STRIPE_EUR,
              source: payment_method_nonce,
              description: description
            }).and_raise(Stripe::CardError.new('oops', 'oops', 'oops'))
          end

          it "doesn't update the order" do
            expect {
              post :checkout, params: order_params
            }.to_not change {
              order.reload.attributes.sort
            }
            controller_ok(302)
          end

          it "redirects to the path of the order" do
            post :checkout, params: order_params
            expect(response).to redirect_to(order_path(order.id))
          end

          it "doesn't result in a confirmation email being sent" do
            expect(UserMailer).to_not receive(:purchase_confirmation)
            post :checkout, params: order_params
          end

        end

      end

      describe "attempting to pay an order I own, which is already paid" do

        let!(:order){ FactoryGirl.create :order, :successfully_paid, user: user }

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
