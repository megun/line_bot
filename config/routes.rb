Rails.application.routes.draw do
  post '/line_bots/callback' => 'line_bots#callback'
end
