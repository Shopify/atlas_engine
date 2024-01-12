# typed: false
# frozen_string_literal: true

AtlasEngine::Engine.routes.draw do
  mount MaintenanceTasks::Engine => "/maintenance_tasks"
  if Rails.env.local?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  get "/connectivity", to: "connectivity#index"
end
