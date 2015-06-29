
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.paths << "#{Rails.root}/vendor/assets/admin_lte"

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( supplier.css supplier.js supplier_cp.css supplier_cp.js pages/* colorgy_front.js classie.js selectFx.js jquery_textfill_min.js main.js velocity_min.js bjqs.js masonry.pkgd.min.js countdown.min.js countdown.min.js )

Rails.application.config.assets.precompile += %w( front/main.js )
