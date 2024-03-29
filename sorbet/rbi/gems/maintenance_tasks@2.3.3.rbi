# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `maintenance_tasks` gem.
# Please instead update this file by running `bin/tapioca gem maintenance_tasks`.

class ActiveRecord::Batches::BatchEnumerator
  include ::ActiveRecordBatchEnumerator
end

# TODO: Remove this patch once all supported Rails versions include the changes
# upstream - https://github.com/rails/rails/pull/42312/commits/a031a43d969c87542c4ee8d0d338d55fcbb53376
#
# source://maintenance_tasks//lib/patches/active_record_batch_enumerator.rb#5
module ActiveRecordBatchEnumerator
  # The size of the batches yielded by the BatchEnumerator.
  #
  # source://maintenance_tasks//lib/patches/active_record_batch_enumerator.rb#18
  def batch_size; end

  # The primary key value at which the BatchEnumerator ends,
  #   inclusive of the value.
  #
  # source://maintenance_tasks//lib/patches/active_record_batch_enumerator.rb#12
  def finish; end

  # The relation from which the BatchEnumerator yields batches.
  #
  # source://maintenance_tasks//lib/patches/active_record_batch_enumerator.rb#15
  def relation; end

  # The primary key value from which the BatchEnumerator starts,
  #   inclusive of the value.
  #
  # source://maintenance_tasks//lib/patches/active_record_batch_enumerator.rb#8
  def start; end
end

# The engine's namespace module. It provides isolation between the host
# application's code and the engine-specific code. Top-level engine constants
# and variables are defined under this module.
#
# source://maintenance_tasks//lib/maintenance_tasks/engine.rb#5
module MaintenanceTasks
  # source://maintenance_tasks//lib/maintenance_tasks.rb#54
  def active_storage_service; end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#54
  def active_storage_service=(val); end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#64
  def backtrace_cleaner; end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#64
  def backtrace_cleaner=(val); end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#73
  def error_handler; end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#73
  def error_handler=(val); end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#32
  def job; end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#32
  def job=(val); end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#91
  def metadata; end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#91
  def metadata=(val); end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#84
  def parent_controller; end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#84
  def parent_controller=(val); end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#22
  def tasks_module; end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#22
  def tasks_module=(val); end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#45
  def ticker_delay; end

  # source://maintenance_tasks//lib/maintenance_tasks.rb#45
  def ticker_delay=(val); end

  class << self
    # The Active Storage service to use for uploading CSV file blobs.
    #
    # @return [Symbol] the key for the storage service, as specified in the
    #   app's config/storage.yml.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#54
    def active_storage_service; end

    # The Active Storage service to use for uploading CSV file blobs.
    #
    # @return [Symbol] the key for the storage service, as specified in the
    #   app's config/storage.yml.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#54
    def active_storage_service=(val); end

    # The Active Support backtrace cleaner that will be used to clean the
    # backtrace of a Task that errors.
    #
    # @return [ActiveSupport::BacktraceCleaner, nil] the backtrace cleaner to
    #   use when cleaning a Run's backtrace.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#64
    def backtrace_cleaner; end

    # The Active Support backtrace cleaner that will be used to clean the
    # backtrace of a Task that errors.
    #
    # @return [ActiveSupport::BacktraceCleaner, nil] the backtrace cleaner to
    #   use when cleaning a Run's backtrace.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#64
    def backtrace_cleaner=(val); end

    # The callback to perform when an error occurs in the Task.  See the
    # {file:README#label-Customizing+the+error+handler} for details.
    #
    # @return [Proc] the callback to perform when an error occurs in the Task.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#73
    def error_handler; end

    # The callback to perform when an error occurs in the Task.  See the
    # {file:README#label-Customizing+the+error+handler} for details.
    #
    # @return [Proc] the callback to perform when an error occurs in the Task.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#73
    def error_handler=(val); end

    # The name of the job to be used to perform Tasks. Defaults to
    # `"MaintenanceTasks::TaskJob"`. This job must be either a class that
    # inherits from {TaskJob} or a class that includes {TaskJobConcern}.
    #
    # @return [String] the name of the job class.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#32
    def job; end

    # The name of the job to be used to perform Tasks. Defaults to
    # `"MaintenanceTasks::TaskJob"`. This job must be either a class that
    # inherits from {TaskJob} or a class that includes {TaskJobConcern}.
    #
    # @return [String] the name of the job class.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#32
    def job=(val); end

    # source://maintenance_tasks//lib/maintenance_tasks.rb#91
    def metadata; end

    # source://maintenance_tasks//lib/maintenance_tasks.rb#91
    def metadata=(val); end

    # The parent controller all web UI controllers will inherit from.
    # Must be a class that inherits from `ActionController::Base`.
    # Defaults to `"ActionController::Base"`
    #
    # @return [String] the name of the parent controller for web UI.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#84
    def parent_controller; end

    # The parent controller all web UI controllers will inherit from.
    # Must be a class that inherits from `ActionController::Base`.
    # Defaults to `"ActionController::Base"`
    #
    # @return [String] the name of the parent controller for web UI.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#84
    def parent_controller=(val); end

    # source://railties/7.1.2/lib/rails/engine.rb#405
    def railtie_helpers_paths; end

    # source://railties/7.1.2/lib/rails/engine.rb#394
    def railtie_namespace; end

    # source://railties/7.1.2/lib/rails/engine.rb#409
    def railtie_routes_url_helpers(include_path_helpers = T.unsafe(nil)); end

    # source://railties/7.1.2/lib/rails/engine.rb#397
    def table_name_prefix; end

    # The module to namespace Tasks in, as a String. Defaults to 'Maintenance'.
    #
    # @return [String] the name of the module.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#22
    def tasks_module; end

    # The module to namespace Tasks in, as a String. Defaults to 'Maintenance'.
    #
    # @return [String] the name of the module.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#22
    def tasks_module=(val); end

    # The delay between updates to the tick count. After each iteration, the
    # progress of the Task may be updated. This duration in seconds limits
    # these updates, skipping if the duration since the last update is lower
    # than this value, except if the job is interrupted, in which case the
    # progress will always be recorded.
    #
    # @return [ActiveSupport::Duration, Numeric] duration of the delay between
    #   updates to the tick count during Task iterations.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#45
    def ticker_delay; end

    # The delay between updates to the tick count. After each iteration, the
    # progress of the Task may be updated. This duration in seconds limits
    # these updates, skipping if the duration since the last update is lower
    # than this value, except if the job is interrupted, in which case the
    # progress will always be recorded.
    #
    # @return [ActiveSupport::Duration, Numeric] duration of the delay between
    #   updates to the tick count during Task iterations.
    #
    # source://maintenance_tasks//lib/maintenance_tasks.rb#45
    def ticker_delay=(val); end

    # source://railties/7.1.2/lib/rails/engine.rb#401
    def use_relative_model_naming?; end
  end
end

class MaintenanceTasks::ApplicationController < ::ActionController::Base
  private

  # source://actionview/7.1.2/lib/action_view/layouts.rb#330
  def _layout(lookup_context, formats); end

  class << self
    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks; end

    # source://actionpack/7.1.2/lib/action_controller/metal.rb#262
    def middleware_stack; end
  end
end

MaintenanceTasks::ApplicationController::BULMA_CDN = T.let(T.unsafe(nil), String)

module MaintenanceTasks::ApplicationController::HelperMethods
  include ::ActionText::ContentHelper
  include ::ActionText::TagHelper
  include ::ActionController::Base::HelperMethods
  include ::MaintenanceTasks::ApplicationHelper
end

module MaintenanceTasks::ApplicationHelper
  def time_ago(datetime); end
end

class MaintenanceTasks::ApplicationRecord < ::ActiveRecord::Base
  include ::MaintenanceTasks::ApplicationRecord::GeneratedAttributeMethods
  include ::MaintenanceTasks::ApplicationRecord::GeneratedAssociationMethods

  class << self
    # source://activemodel/7.1.2/lib/active_model/validations.rb#71
    def _validators; end

    # source://activerecord/7.1.2/lib/active_record/enum.rb#167
    def defined_enums; end
  end
end

module MaintenanceTasks::ApplicationRecord::GeneratedAssociationMethods; end
module MaintenanceTasks::ApplicationRecord::GeneratedAttributeMethods; end

class MaintenanceTasks::BatchCsvCollectionBuilder < ::MaintenanceTasks::CsvCollectionBuilder
  def initialize(batch_size); end

  def collection(task); end
  def count(task); end
end

class MaintenanceTasks::BatchCsvCollectionBuilder::BatchCsv < ::Struct
  def batch_size; end
  def batch_size=(_); end
  def csv; end
  def csv=(_); end

  class << self
    def [](*_arg0); end
    def inspect; end
    def keyword_init?; end
    def members; end
    def new(*_arg0); end
  end
end

class MaintenanceTasks::CsvCollectionBuilder
  def collection(task); end
  def count(task); end
  def has_csv_content?; end
  def no_collection?; end
end

# The engine's main class, which defines its namespace. The engine is mounted
# by the host application.
#
# source://maintenance_tasks//lib/maintenance_tasks/engine.rb#8
class MaintenanceTasks::Engine < ::Rails::Engine
  class << self
    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks; end
  end
end

class MaintenanceTasks::NoCollectionBuilder
  def collection(_task); end
  def count(_task); end
  def has_csv_content?; end
  def no_collection?; end
end

class MaintenanceTasks::NullCollectionBuilder
  def collection(task); end
  def count(task); end
  def has_csv_content?; end
  def no_collection?; end
end

class MaintenanceTasks::Progress
  include ::ActiveSupport::NumberHelper
  include ::ActionView::Helpers::SanitizeHelper
  include ::ActionView::Helpers::CaptureHelper
  include ::ActionView::Helpers::OutputSafetyHelper
  include ::ActionView::Helpers::TagHelper
  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::SanitizeHelper::ClassMethods

  def initialize(run); end

  def max; end
  def text; end
  def value; end

  private

  def estimatable?; end
  def over_total?; end
  def total?; end
end

class MaintenanceTasks::Run < ::MaintenanceTasks::ApplicationRecord
  include ::MaintenanceTasks::Run::GeneratedAttributeMethods
  include ::MaintenanceTasks::Run::GeneratedAssociationMethods

  def active?; end

  # source://activerecord/7.1.2/lib/active_record/autosave_association.rb#160
  def autosave_associated_records_for_csv_file_attachment(*args); end

  # source://activerecord/7.1.2/lib/active_record/autosave_association.rb#160
  def autosave_associated_records_for_csv_file_blob(*args); end

  def cancel; end
  def complete; end
  def completed?; end
  def csv_attachment_presence; end
  def csv_content_type; end
  def csv_file; end
  def enqueued!; end
  def job_shutdown; end
  def pausing!; end
  def persist_error(error); end
  def persist_progress(number_of_ticks, duration); end
  def persist_transition; end
  def reload_status; end
  def running; end
  def start(count); end
  def started?; end
  def stopped?; end
  def stopping?; end
  def stuck?; end
  def task; end
  def task_name_belongs_to_a_valid_task; end
  def time_to_completion; end
  def validate_task_arguments; end

  private

  def arguments_match_task_attributes; end
  def run_error_callback; end
  def run_task_callbacks(callback); end
  def truncate(attribute_name, value); end

  class << self
    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks; end

    # source://activerecord/7.1.2/lib/active_record/readonly_attributes.rb#11
    def _attr_readonly; end

    # source://activerecord/7.1.2/lib/active_record/reflection.rb#11
    def _reflections; end

    # source://activemodel/7.1.2/lib/active_model/validations.rb#71
    def _validators; end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def active(*args, **_arg1); end

    # source://activestorage/7.1.2/lib/active_storage/reflection.rb#53
    def attachment_reflections; end

    # source://activerecord/7.1.2/lib/active_record/attributes.rb#11
    def attributes_to_define_after_schema_loads; end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def cancelled(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def cancelling(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def completed(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/enum.rb#167
    def defined_enums; end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def enqueued(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def errored(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def interrupted(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_cancelled(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_cancelling(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_enqueued(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_errored(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_interrupted(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_paused(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_pausing(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_running(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def not_succeeded(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def paused(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def pausing(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def running(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/enum.rb#242
    def statuses; end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def succeeded(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def with_attached_csv(*args, **_arg1); end

    # source://activerecord/7.1.2/lib/active_record/scoping/named.rb#174
    def with_attached_csv_file(*args, **_arg1); end
  end
end

MaintenanceTasks::Run::ACTIVE_STATUSES = T.let(T.unsafe(nil), Array)
MaintenanceTasks::Run::CALLBACKS_TRANSITION = T.let(T.unsafe(nil), Hash)
MaintenanceTasks::Run::COMPLETED_STATUSES = T.let(T.unsafe(nil), Array)

module MaintenanceTasks::Run::GeneratedAssociationMethods
  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#32
  def build_csv_file_attachment(*args, &block); end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#32
  def build_csv_file_blob(*args, &block); end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#36
  def create_csv_file_attachment(*args, &block); end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#40
  def create_csv_file_attachment!(*args, &block); end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#36
  def create_csv_file_blob(*args, &block); end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#40
  def create_csv_file_blob!(*args, &block); end

  # source://activestorage/7.1.2/lib/active_storage/attached/model.rb#99
  def csv_file; end

  # source://activestorage/7.1.2/lib/active_storage/attached/model.rb#104
  def csv_file=(attachable); end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/association.rb#103
  def csv_file_attachment; end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/association.rb#111
  def csv_file_attachment=(value); end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/association.rb#103
  def csv_file_blob; end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/association.rb#111
  def csv_file_blob=(value); end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#19
  def reload_csv_file_attachment; end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#19
  def reload_csv_file_blob; end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#23
  def reset_csv_file_attachment; end

  # source://activerecord/7.1.2/lib/active_record/associations/builder/singular_association.rb#23
  def reset_csv_file_blob; end
end

module MaintenanceTasks::Run::GeneratedAttributeMethods; end
MaintenanceTasks::Run::STATUSES = T.let(T.unsafe(nil), Array)
MaintenanceTasks::Run::STOPPING_STATUSES = T.let(T.unsafe(nil), Array)
MaintenanceTasks::Run::STUCK_TASK_TIMEOUT = T.let(T.unsafe(nil), ActiveSupport::Duration)

class MaintenanceTasks::RunStatusValidator < ::ActiveModel::Validator
  def validate(record); end

  private

  def add_invalid_status_error(record, previous_status, new_status); end
end

MaintenanceTasks::RunStatusValidator::VALID_STATUS_TRANSITIONS = T.let(T.unsafe(nil), Hash)

module MaintenanceTasks::Runner
  extend ::MaintenanceTasks::Runner

  def resume(run); end
  def run(name:, csv_file: T.unsafe(nil), arguments: T.unsafe(nil), run_model: T.unsafe(nil), metadata: T.unsafe(nil)); end

  private

  def enqueue(run, job); end
  def filename(task_name); end
  def instantiate_job(run); end
end

class MaintenanceTasks::Runner::EnqueuingError < ::StandardError
  def initialize(run); end

  def run; end
end

class MaintenanceTasks::RunsController < ::MaintenanceTasks::ApplicationController
  def cancel; end
  def create(&block); end
  def pause; end
  def resume; end

  private

  # source://actionview/7.1.2/lib/action_view/layouts.rb#330
  def _layout(lookup_context, formats); end

  def set_run; end

  class << self
    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks; end

    # source://actionpack/7.1.2/lib/action_controller/metal.rb#262
    def middleware_stack; end
  end
end

class MaintenanceTasks::RunsPage
  def initialize(runs, cursor); end

  def last?; end
  def next_cursor; end
  def records; end
end

MaintenanceTasks::RunsPage::RUNS_PER_PAGE = T.let(T.unsafe(nil), Integer)

class MaintenanceTasks::Task
  include ::ActiveSupport::Callbacks
  include ::ActiveModel::AttributeRegistration
  include ::ActiveModel::AttributeMethods
  include ::ActiveModel::Attributes
  include ::ActiveModel::ForbiddenAttributesProtection
  include ::ActiveModel::AttributeAssignment
  include ::ActiveModel::Validations
  include ::ActiveModel::Validations::HelperMethods
  extend ::ActiveSupport::DescendantsTracker
  extend ::ActiveSupport::Callbacks::ClassMethods
  extend ::ActiveModel::AttributeRegistration::ClassMethods
  extend ::ActiveModel::AttributeMethods::ClassMethods
  extend ::ActiveModel::Attributes::ClassMethods
  extend ::ActiveModel::Validations::ClassMethods
  extend ::ActiveModel::Naming
  extend ::ActiveModel::Callbacks
  extend ::ActiveModel::Translation
  extend ::ActiveModel::Validations::HelperMethods

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
  def __callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
  def __callbacks?; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _cancel_callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _complete_callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _error_callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _interrupt_callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _pause_callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_cancel_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_complete_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_error_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_interrupt_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_pause_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_start_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_validate_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _start_callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _validate_callbacks; end

  # source://activemodel/7.1.2/lib/active_model/validations.rb#71
  def _validators; end

  # source://activemodel/7.1.2/lib/active_model/validations.rb#71
  def _validators?; end

  # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#72
  def attribute_aliases; end

  # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#72
  def attribute_aliases?; end

  # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#73
  def attribute_method_patterns; end

  # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#73
  def attribute_method_patterns?; end

  def collection; end
  def collection_builder_strategy; end
  def collection_builder_strategy=(_arg0); end
  def collection_builder_strategy?; end
  def count; end
  def csv_content; end
  def csv_content=(csv_content); end
  def has_csv_content?; end

  # source://activemodel/7.1.2/lib/active_model/naming.rb#255
  def model_name(&block); end

  def no_collection?; end
  def process(_item); end
  def throttle_conditions; end
  def throttle_conditions=(_arg0); end
  def throttle_conditions?; end

  # source://activemodel/7.1.2/lib/active_model/validations.rb#67
  def validation_context; end

  private

  # source://activemodel/7.1.2/lib/active_model/validations.rb#67
  def validation_context=(_arg0); end

  class << self
    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks?; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _cancel_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _cancel_callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _complete_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _complete_callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _error_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _error_callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _interrupt_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _interrupt_callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _pause_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _pause_callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _start_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _start_callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _validate_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _validate_callbacks=(value); end

    # source://activemodel/7.1.2/lib/active_model/validations.rb#71
    def _validators; end

    # source://activemodel/7.1.2/lib/active_model/validations.rb#71
    def _validators=(value); end

    # source://activemodel/7.1.2/lib/active_model/validations.rb#71
    def _validators?; end

    def after_cancel(*filter_list, &block); end
    def after_complete(*filter_list, &block); end
    def after_error(*filter_list, &block); end
    def after_interrupt(*filter_list, &block); end
    def after_pause(*filter_list, &block); end
    def after_start(*filter_list, &block); end

    # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#72
    def attribute_aliases; end

    # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#72
    def attribute_aliases=(value); end

    # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#72
    def attribute_aliases?; end

    # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#73
    def attribute_method_patterns; end

    # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#73
    def attribute_method_patterns=(value); end

    # source://activemodel/7.1.2/lib/active_model/attribute_methods.rb#73
    def attribute_method_patterns?; end

    def available_tasks; end
    def collection; end
    def collection_builder_strategy; end
    def collection_builder_strategy=(value); end
    def collection_builder_strategy?; end
    def count; end
    def csv_collection(in_batches: T.unsafe(nil)); end
    def has_csv_content?(*_arg0, **_arg1, &_arg2); end
    def load_all; end
    def named(name); end
    def no_collection; end
    def no_collection?(*_arg0, **_arg1, &_arg2); end
    def process(*args); end
    def throttle_conditions; end
    def throttle_conditions=(value); end
    def throttle_conditions?; end
    def throttle_on(backoff: T.unsafe(nil), &condition); end

    private

    def load_constants; end
  end
end

class MaintenanceTasks::Task::NotFoundError < ::NameError; end

class MaintenanceTasks::TaskDataIndex
  def initialize(name, related_run = T.unsafe(nil)); end

  def category; end
  def name; end
  def related_run; end
  def status; end
  def to_s; end

  class << self
    def available_tasks; end
  end
end

class MaintenanceTasks::TaskDataShow
  def initialize(name); end

  def active_runs; end
  def code; end
  def completed_runs; end
  def csv_task?; end
  def deleted?; end
  def name; end
  def new; end
  def parameter_names; end
  def to_s; end

  private

  def runs; end
end

class MaintenanceTasks::TaskJob < ::ActiveJob::Base
  include ::JobIteration::Iteration
  include ::MaintenanceTasks::TaskJobConcern
  extend ::JobIteration::Iteration::ClassMethods
  extend ::MaintenanceTasks::TaskJobConcern::ClassMethods
  extend ::JobIteration::Iteration::PrependedClassMethods

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _complete_callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_complete_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_shutdown_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#951
  def _run_start_callbacks(&block); end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _shutdown_callbacks; end

  # source://activesupport/7.1.2/lib/active_support/callbacks.rb#963
  def _start_callbacks; end

  # source://job-iteration/1.4.1/lib/job-iteration/iteration.rb#48
  def job_iteration_max_job_runtime; end

  class << self
    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _complete_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _complete_callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _shutdown_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _shutdown_callbacks=(value); end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#955
    def _start_callbacks; end

    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#959
    def _start_callbacks=(value); end

    # source://job-iteration/1.4.1/lib/job-iteration/iteration.rb#48
    def job_iteration_max_job_runtime; end

    # source://job-iteration/1.4.1/lib/job-iteration/iteration.rb#59
    def job_iteration_max_job_runtime=(new); end

    # source://activesupport/7.1.2/lib/active_support/rescuable.rb#15
    def rescue_handlers; end
  end
end

module MaintenanceTasks::TaskJobConcern
  extend ::ActiveSupport::Concern
  include GeneratedInstanceMethods
  include ::JobIteration::Iteration

  mixes_in_class_methods GeneratedClassMethods
  mixes_in_class_methods ::JobIteration::Iteration::ClassMethods
  mixes_in_class_methods ::MaintenanceTasks::TaskJobConcern::ClassMethods
  mixes_in_class_methods ::JobIteration::Iteration::PrependedClassMethods

  private

  def after_perform; end
  def before_perform; end
  def build_enumerator(_run, cursor:); end
  def each_iteration(input, _run); end
  def on_complete; end
  def on_error(error); end
  def on_shutdown; end
  def on_start; end
  def reenqueue_iteration_job(should_ignore: T.unsafe(nil)); end
  def task_iteration(input); end
  def throttle_enumerator(collection_enum); end

  module GeneratedClassMethods
    def job_iteration_max_job_runtime; end
    def job_iteration_max_job_runtime=(value); end
  end

  module GeneratedInstanceMethods
    def job_iteration_max_job_runtime; end
  end
end

module MaintenanceTasks::TaskJobConcern::ClassMethods
  def retry_on(*_arg0, **_arg1); end
end

class MaintenanceTasks::TasksController < ::MaintenanceTasks::ApplicationController
  def index; end
  def show; end

  private

  # source://actionview/7.1.2/lib/action_view/layouts.rb#330
  def _layout(lookup_context, formats); end

  def set_refresh; end

  class << self
    # source://activesupport/7.1.2/lib/active_support/callbacks.rb#70
    def __callbacks; end

    # source://actionpack/7.1.2/lib/action_controller/metal.rb#262
    def middleware_stack; end
  end
end

module MaintenanceTasks::TasksController::HelperMethods
  include ::ActionText::ContentHelper
  include ::ActionText::TagHelper
  include ::ActionController::Base::HelperMethods
  include ::MaintenanceTasks::ApplicationHelper
  include ::MaintenanceTasks::ApplicationController::HelperMethods
  include ::MaintenanceTasks::TasksHelper
end

module MaintenanceTasks::TasksHelper
  def csv_file_download_path(run); end
  def datetime_field_help_text; end
  def format_backtrace(backtrace); end
  def highlight_code(code); end
  def parameter_field(form_builder, parameter_name); end
  def progress(run); end
  def status_tag(status); end
  def time_running_in_words(run); end
end

MaintenanceTasks::TasksHelper::STATUS_COLOURS = T.let(T.unsafe(nil), Hash)

class MaintenanceTasks::Ticker
  def initialize(throttle_duration, &persist); end

  def persist; end
  def tick; end

  private

  def persist?; end
end
