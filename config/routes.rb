AtlasEngine::Engine.routes.draw do
  mount MaintenanceTasks::Engine => "atlas_engine/maintenance_tasks"
  if Rails.env.development? || Rails.env.test?
    mount GraphiQL::Rails::Engine, at: "atlas_engine/graphiql", graphql_path: "/atlas_engine/graphql"
  end
  post "atlas_engine/graphql", to: "graphql#execute"
  get "atlas_engine/connectivity", to: "connectivity#index"
end
