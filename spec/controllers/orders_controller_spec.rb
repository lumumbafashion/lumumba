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

end
