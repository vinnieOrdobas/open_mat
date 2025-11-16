# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 1. Add your local React app's URL
    # 2. Add your *future* Vercel production URL
    # 3. We'll also add a "wildcard" for Vercel preview deploys
    origins "http://localhost:5173",
            "https://openmat-frontend.vercel.app",
            /\.vercel\.app$/ # Allows all Vercel subdomains (for previews)

    resource "*",
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             # 3. We MUST expose the Authorization header so the frontend can read it
             expose: ['Authorization']
  end
end