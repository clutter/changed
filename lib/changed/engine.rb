module Changed
  class Engine < ::Rails::Engine
    isolate_namespace Changed

    config.generators do |generator|
      generator.test_framework :rspec
      generator.fixture_replacement :factory_bot, dir: 'spec/factories'
    end
  end
end
