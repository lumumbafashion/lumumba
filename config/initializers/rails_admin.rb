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

end
