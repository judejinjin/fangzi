require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StreetEasyClone
  class Application < Rails::Application
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = [:en, :cn]
    config.i18n.default_locale = :cn

    config.generators do |g|
      g.test_framework :rspec,
        :fixtures => true,
        :view_specs => false,
        :helper_specs => false,
        :routing_specs => false,
        :controller_specs => true,
        :request_specs => true
    end

    config.paperclip_defaults = {
      :storage => :s3,
      :s3_protocol => 'http',
      :url =>':s3_domain_url',
      :path => "images/:class/:id.:style.:extension",
      :s3_credentials => {
        :bucket => ENV['AWS_BUCKET'], #these values safely stored in application.yml thanks to figaro!
        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
        :s3_region => ENV['AWS_REGION']
      }
    }
  end

end
