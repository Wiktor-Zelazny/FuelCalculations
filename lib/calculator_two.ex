defmodule FuelCalculator.CalculatorTwo do
  @earth 9.807
  @mars 3.711
  @moon 1.62
  def get_launch_fuel_for(origin, payload_mass) do
    origin
    |> get_gravity_for()
    |> gross_launch_fuel_for(payload_mass)
    |> validate_fuel_load()
  end

  def gross_launch_fuel_for(origin_gravity, payload_mass)
      when is_number(origin_gravity) and
             is_number(payload_mass) do
    origin_gravity * payload_mass * 0.042 - 33
  end

  def gross_launch_fuel_for(invalid_gravity, invalid_payload) do
    # Logger.error("Invalid fuel parameters: Origin gravity#{IO.inspect(invalid_gravity)}, Payload: #{IO.inspect(invalid_payload)}")
    {:error, {"Invalid launch parameters", [invalid_gravity, invalid_payload]}}
  end

  def validate_fuel_load(load) do
    case load do
      error = {:error, _} -> error
      fuel_load when fuel_load > 0 -> floor(fuel_load)
      _ -> {:error, :payload_to_small}
    end
  end

  def get_gravity_for(planet_name) do
    case planet_name do
      "Earth" -> @earth
      "Mars" -> @mars
      "Moon" -> @moon
      other_name -> other_name
    end
  end
end
