RailsAdmin.config do |config|

  RailsAdmin.config do |config|
    config.authorize_with do
      redirect_to main_app.root_path unless current_user.try(:admin)
    end
  end

  config.actions do
    dashboard
    index
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end

  config.model 'Article' do
    edit do
      field :description, :ck_editor
      include_all_fields
    end
  end

  config.model 'Product' do
    edit do
      field :name
      field :slug
      field :price
      field :initial_stock
      field :description
      field :designer
      field :main_image
      field :first_thumbnail
      field :second_thumbnail
      field :third_thumbnail
      field :preview
      field :about_designer, :ck_editor
      field :about_lumumba, :ck_editor
      include_all_fields
    end
  end

end
