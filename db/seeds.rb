if Rails.env.development?

  # OrderItem.destroy_all
  # Order.destroy_all
  # Design.destroy_all
  # Product.destroy_all
  # Article.destroy_all
  # User.destroy_all
  #
  # FactoryGirl.create :user, email: 'vemv@vemv.net', password: 'p', password_confirmation: 'p'
  # user = User.last
  #
  # img = "http://wpthemes.icynets.com/centilium/wp-content/uploads/sites/4/2014/09/Fashion-Top-Models-0017.jpg"
  # 10.times { FactoryGirl.create :article }
  # 10.times { FactoryGirl.create :product }
  # 10.times do
  #    FactoryGirl.create(:design,
  #     user_id: user.id
  #   )
  # end
  #
  #   10.times { FactoryGirl.create(:order, user_id: user.id)}

  user = User.find_by(email: "vemv@vemv.net")

    products = Product.all

    orders = Order.all.each do |order|
      order.user_id = user.id
      order.save
    end

    OrderItem.destroy_all

    20.times do
      FactoryGirl.create(:order_item, product: products[rand(2..8)], order: orders[rand(2..8)] )
    end
    puts "User #{User.count}"
    puts "Articles #{Article.count}"
    puts "Products #{Product.count}"
    puts "Designs #{Design.count}"
    puts "Order #{Order.count}"
    puts "Order Items #{OrderItem.count}"
end

countries = [['BE',	0.21],
             ['BG', 0.20],
             ['CZ', 0.21],
             ['DK', 0.25],
             ['DE', 0.19],
             ['EE', 0.20],
             ['IE', 0.23],
             ['GR', 0.24],
             ['ES', 0.21],
             ['FR', 0.20],
             ['HR', 0.25],
             ['IT', 0.22],
             ['CY', 0.19],
             ['LV', 0.21],
             ['LT', 0.21],
             ['LU', 0.17],
             ['HU', 0.27],
             ['MT', 0.18],
             ['NL', 0.21],
             ['AT', 0.20],
             ['PL', 0.23],
             ['PT', 0.23],
             ['RO', 0.20],
             ['SI', 0.22],
             ['SK', 0.20],
             ['FI', 0.24],
             ['SE', 0.25],
             ['GB', 0.20]]

countries.each do |country|
  country = Tax.create(country: country[0], vat_rate: country[1])
end
