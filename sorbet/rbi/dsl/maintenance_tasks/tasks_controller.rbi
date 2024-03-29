# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `MaintenanceTasks::TasksController`.
# Please instead update this file by running `bin/tapioca dsl MaintenanceTasks::TasksController`.

class MaintenanceTasks::TasksController
  sig { returns(HelperProxy) }
  def helpers; end

  module HelperMethods
    include ::ActionText::ContentHelper
    include ::ActionText::TagHelper
    include ::ActionController::Base::HelperMethods
    include ::MaintenanceTasks::ApplicationHelper
    include ::MaintenanceTasks::ApplicationController::HelperMethods
    include ::MaintenanceTasks::TasksHelper
  end

  class HelperProxy < ::ActionView::Base
    include HelperMethods
  end
end
