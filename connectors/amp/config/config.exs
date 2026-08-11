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

  config :jido_integration_v2_control_plane, :persistence,
    profile: :mickey_mouse,
    store_modules: %{
      run_store: Jido.Integration.V2.ControlPlane.RunLedger,
      attempt_store: Jido.Integration.V2.ControlPlane.RunLedger,
      recovery_task_store: Jido.Integration.V2.ControlPlane.RunLedger,
      event_store: Jido.Integration.V2.ControlPlane.RunLedger,
      artifact_store: Jido.Integration.V2.ControlPlane.RunLedger,
      claim_check_store: Jido.Integration.V2.ControlPlane.RunLedger,
      target_store: Jido.Integration.V2.ControlPlane.RunLedger,
      ingress_store: Jido.Integration.V2.ControlPlane.RunLedger,
      profile_registry_store: Jido.Integration.V2.ControlPlane.RunLedger
    }
end

