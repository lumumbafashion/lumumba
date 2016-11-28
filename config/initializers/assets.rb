Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
Rails.application.config.assets.precompile += %w(main.css)
Rails.application.config.assets.precompile += %w(marcos.css)
Rails.application.config.assets.precompile += %w(drop-theme-arrows.css)
Rails.application.config.assets.precompile += %w(pagination.css)
Rails.application.config.assets.precompile += %w(select-theme-defaults.css)
Rails.application.config.assets.precompile += %w(tether.min.css)
Rails.application.config.assets.precompile += %w(tether.min.js)
Rails.application.config.assets.precompile += %w(select.min.js)
Rails.application.config.assets.precompile += %w(drop.min.js)
Rails.application.config.assets.precompile += %w(main.js ckeditor/lang/es.js ckeditor/lang/en.js)
