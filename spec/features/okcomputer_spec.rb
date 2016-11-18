require 'rails_helper'
require 'spec_helper'

describe 'Hitting the OkComputer endpoints' do

  describe 'refering the endpoints by constant access' do

      describe 'the base endpoint' do

        it "works" do
          visit LUMUMBA_HEALTH_PATH
          page_ok
        end

      end

      describe 'the /all endpoint' do

        it "works" do
          visit "#{LUMUMBA_HEALTH_PATH}/all"
          page_ok
        end

      end

  end

  describe 'refering the endpoints by path helper access' do

      describe 'the base endpoint' do

        it "works" do
          visit OkComputer::Engine.routes.url_helpers.okcomputer_check_path(check: 'default')
          page_ok
        end

      end

      describe 'the /all endpoint' do

        it "works" do
          visit OkComputer::Engine.routes.url_helpers.okcomputer_checks_path
          page_ok
        end

      end

  end

end
