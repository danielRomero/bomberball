WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name
  #
  # Here is an example of mapping namespaced events:
  #   namespace :product do
  #     subscribe :new, :to => ProductController, :with_method => :new_product
  #   end
  # The above will handle an event triggered on the client like `product.new`.

  subscribe :player_connected,        to: GameConnectionsController, with_method: :player_connected
  subscribe :player_disconnected,     to: GameConnectionsController, with_method: :player_disconnected
  subscribe :update_movement,         to: GameConnectionsController, with_method: :update_movement
  subscribe :update_grid,             to: GameConnectionsController, with_method: :update_grid
  subscribe :sync_grid,               to: GameConnectionsController, with_method: :update_grid

  subscribe :new_user,                to: GameConnectionsController, with_method: :new_user

  # The :client_connected method is fired automatically when a new client connects
  #subscribe :client_connected, :to => ChatController, :with_method => :client_connected
  # The :client_disconnected method is fired automatically when a client disconnects
  #subscribe :client_disconnected, :to => ChatController, :with_method => :delete_user
end
