AtlasEngine::Engine.routes.draw do
  mount AtlasEngine::Engine => "/atlas_engine/"
  mount MaintenanceTasks::Engine => "/maintenance_tasks"
  if Rails.env.development? || Rails.env.test?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/atlas_engine/graphql"
  end
  post "/graphql", to: "graphql#execute"
  get "/connectivity", to: "connectivity#index"
end
