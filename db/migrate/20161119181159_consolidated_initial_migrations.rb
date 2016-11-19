class ConsolidatedInitialMigrations < ActiveRecord::Migration[5.0]

  def up

    # DeviseCreateUsers ------------------------------
    create_table :users do |t|
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true

    # AddOmniauthToUsers ------------------------------
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :image, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :gender, :string

    # AddPhoneNumberAndDescriptionToUsers ------------------------------

    add_column :users, :phone_number, :string
    add_column :users, :description, :string

    # CreateFriendlyIdSlugs ------------------------------

    create_table :friendly_id_slugs do |t|
      t.string   :slug,           null: false
      t.integer  :sluggable_id,   null: false
      t.string   :sluggable_type, limit: 50
      t.string   :scope
      t.datetime :created_at
    end

    add_index :friendly_id_slugs, :sluggable_id
    add_index :friendly_id_slugs, [:slug, :sluggable_type]
    add_index :friendly_id_slugs, [:slug, :sluggable_type, :scope], unique: true
    add_index :friendly_id_slugs, :sluggable_type

    # AddSlugsToUsers ------------------------------
    add_column :users, :slug, :string
    add_index :users, :slug, unique: true

    # AddImageStatusToUsers ------------------------------
    add_column :users, :image_status, :string

    # AddAvatarToUsers ------------------------------
    add_column :users, :avatar, :string

    # CreateDesigns ------------------------------
    create_table :designs do |t|
      t.string :image, null: false
      t.string :image_desc, null: false
      t.string :first_garment_model_design
      t.string :first_garment_print_design, null: false
      t.string :first_garment_technical_design
      t.string :first_garment_desc, null: false
      t.string :second_garment_model_design
      t.string :second_garment_print_design, null: false
      t.string :second_garment_technical_design
      t.string :second_garment_desc, null: false
      t.string :third_garment_model_design
      t.string :third_garment_print_design, null: false
      t.string :third_garment_technical_design
      t.boolean :for_competition, null: false
      t.boolean :competition, null: false
      t.references :user, foreign_key: true
      t.timestamps null: false
    end

    # AddThirdGarmentDescToDesigns ------------------------------
    add_column :designs, :third_garment_desc, :string

    # CreateArticles ------------------------------
    create_table :articles do |t|
      t.string :title, null: false
      t.string :image, null: false
      t.text :description, null: false
      t.string :author, null: false
      t.timestamps null: false
    end

    # AddTopPostAndValidPostToArticles ------------------------------
    add_column :articles, :top_post, :boolean
    add_column :articles, :valid_post, :boolean

    # AddUserIdToArticles ------------------------------
    add_reference :articles, :user, foreign_key: true

    # AddGarmentDesignToDesigns ------------------------------
    add_column :designs, :first_garment_design, :string
    add_column :designs, :second_garment_design, :string
    add_column :designs, :third_garment_design, :string

    # CreateAddresses ------------------------------
    create_table :addresses do |t|
      t.string :street_address, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip_code, null: false
      t.string :country, null: false
      t.references :user, foreign_key: true
      t.timestamps null: false
    end

    # ActsAsVotableMigration  ------------------------------
    create_table :votes do |t|
      t.references :votable, polymorphic: true
      t.references :voter, polymorphic: true
      t.boolean :vote_flag
      t.string :vote_scope
      t.integer :vote_weight
      t.timestamps null: false
    end

    add_index :votes, [:voter_id, :voter_type, :vote_scope]
    add_index :votes, [:votable_id, :votable_type, :vote_scope]

    # CreateProducts ------------------------------
    create_table :products do |t|
      t.string :name, null: false
      t.string :main_image, null: false
      t.string :first_thumbnail, null: false
      t.string :second_thumbnail, null: false
      t.string :third_thumbnail, null: false
      t.decimal :price, null: false
      t.string :description, null: false
      t.string :designer, null: false
      t.boolean :preview, default: false
      t.timestamps null: false
    end

    # CreateOrders ------------------------------
    create_table :orders do |t|
      t.string :order_number, null: false
      t.string :payment_method
      t.decimal :total_amount
      t.string :status, null: false
      t.references :user, foreign_key: true
      t.timestamps null: false
    end

    # CreateOrderItems ------------------------------
    create_table :order_items do |t|
      t.integer :quantity, null: false
      t.string :size, null: false
      t.references :product, foreign_key: true
      t.references :order, foreign_key: true
      t.timestamps null: false
    end

    # AddVatToOrders ------------------------------
    add_column :orders, :vat, :decimal

    # CreateTaxes ------------------------------
    create_table :taxes do |t|
      t.string :country, null: false
      t.decimal :vat_rate, null: false
      t.timestamps null: false
    end

    # AddAddressToOrders ------------------------------
    add_column :orders, :shipping, :integer
    add_column :orders, :transaction_id, :string
    add_column :orders, :sub_total, :decimal, default: 0.0
    add_column :orders, :shipping_cost, :decimal, default: 0.0

    # AddLocationToUsers ------------------------------
    add_column :users, :location, :string

    # AddSlugToOrders ------------------------------
    add_column :orders, :slug, :string
    add_index :orders, :slug, unique: true

    # AddSlugToProducts ------------------------------
    add_column :products, :slug, :string
    add_index :products, :slug, unique: true

    # AddAdminToUsers ------------------------------
    add_column :users, :admin, :boolean, default: false

    # CreateMessages ------------------------------
    create_table :messages do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :message, null: false
      t.timestamps null: false
    end

    # CreateNotifications ------------------------------
    create_table :notifications do |t|
      t.string :notice, null: false
      t.references :user, foreign_key: true
      t.timestamps null: false
    end

  end
end
