AtlasEngineTestOne::Engine.routes.draw do
  if Rails.env.development? || Rails.env.test?
    #mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/atlas_engine_test_one/graphql"
  end
  post "/graphql", to: "graphql#execute"
end
