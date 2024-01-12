# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  mount AtlasEngine::Engine => "/"
end
