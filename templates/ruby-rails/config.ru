# Smallest useful Rails application: one file, no database, JSON only.
require "bundler/setup"
require "action_controller/railtie"

class SampleApp < Rails::Application
  config.root = __dir__
  config.eager_load = true
  config.api_only = true
  config.hosts.clear
  config.logger = ActiveSupport::Logger.new($stdout)
  # Set SECRET_KEY_BASE in real deployments; the random fallback only suits this stateless sample.
  config.secret_key_base = ENV.fetch("SECRET_KEY_BASE") { SecureRandom.hex(64) }

  routes.append do
    root to: "sample#index"
    get "/health", to: "sample#health"
  end
end

class SampleController < ActionController::API
  def index
    render plain: "Hello from Rails\n"
  end

  def health
    render json: { status: "ok" }
  end
end

Rails.application.initialize!
run Rails.application
