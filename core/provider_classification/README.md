# Jido Integration Provider Classification

Current release: `0.1.0` (2026-08-10).

This package owns the dependency-light provider and adapter classification
vocabulary shared by Jido Integration, Citadel, OuterBrain, StackLab, and other
generic platform packages.

It contains no connector runtime dependencies. Packages that only need to
classify provider vocabulary should depend on this package instead of the full
`jido_integration_contracts` package.

## Installation

```elixir
def deps do
  [
    {:jido_integration_provider_classification, "~> 0.1.0"}
  ]
end
```
