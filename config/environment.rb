# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
Rails.application.configure do
  config.active_record.belongs_to_required_by_default = false
end
