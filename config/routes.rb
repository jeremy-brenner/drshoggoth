CanvasExperiment::Application.routes.draw do
  root to: "application#index"
  get '/trex', to: 'application#trex'
  get '/vapors', to: 'application#vapors'
end
