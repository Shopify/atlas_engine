# typed: false
# frozen_string_literal: true

module AtlasEngine
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    layout "mailer"
  end
end
