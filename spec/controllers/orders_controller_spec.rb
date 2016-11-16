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

end
