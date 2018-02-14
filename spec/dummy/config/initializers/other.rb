Rails.application.config.filter_parameters += [:password]

Rails.application.config.action_dispatch.cookies_serializer = :json

ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end
