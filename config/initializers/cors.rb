Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV["CORS_ORIGIN"]

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "access-token", "expiry", "token-type", "uid", "client" ],
      credentials: true

    resource "/cable",
      headers: :any,
      methods: [ :get, :post, :options ],
      credentials: true
  end
end
