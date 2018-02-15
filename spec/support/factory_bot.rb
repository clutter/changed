require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.definition_file_paths = %w[./spec/factories ./spec/dummy/spec/factories]
FactoryBot.find_definitions
