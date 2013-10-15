CanvasExperiment::Application.routes.draw do
  root to: "application#index"
  get '/trex', to: 'application#index'
end
