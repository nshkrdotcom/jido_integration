import Config

if config_env() == :test do
  config :jido_integration_v2_auth, :persistence,
    profile: :mickey_mouse,
    store_modules: %{
      credential_store: Jido.Integration.V2.Auth.Store,
      lease_store: Jido.Integration.V2.Auth.Store,
      connection_store: Jido.Integration.V2.Auth.Store,
      install_store: Jido.Integration.V2.Auth.Store
    }
end
