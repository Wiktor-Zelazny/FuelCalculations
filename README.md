# FuelCalculator
The fuel calculator for launching and landing payload in given gravity using provided formula. The module Calculator https://github.com/Wiktor-Zelazny/FuelCalculations/blob/main/lib/calculator.ex provides three functions get_$operation_fuel_for calculating fuel needed to launch, land or total fuel for launch and land given payload on given celestial bodies. The total fuel load accounts for extra fuel neded to launch mass of fuel that will be used in landing.

TODO: Enable Logger for the module(lines for use of Logger are present but commented away until they can be used). 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fuel_calculator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fuel_calculator, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fuel_calculator](https://hexdocs.pm/fuel_calculator).

# FuelCalculations
