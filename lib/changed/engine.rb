module Changed
  class Engine < ::Rails::Engine
    isolate_namespace Changed

    config.generators do |generator|
      generator.test_framework :rspec
    end
  end
end
