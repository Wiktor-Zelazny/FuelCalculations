defmodule FuelCalculator.Calculator do
  @earth 9.807
  @mars 3.711
  @moon 1.62

  @doc """
  Calculates fuel needed to launch a payload mass from origin gravity.
  Usage: get_launch_fuel_for(origin, payload_mass)
  origin can be a number or string "Earth", "Mars" or "Moon"
  payload_mass must be a sufficiently large number (formulas does not return positive fuel weight
  for small enough mass)

  Returns {:ok, fuel_load} for valid arguments.
  Returns {:error, :payload_to_light} if payload weight is to small to apply the formulas
  Returns {:error, {"Invalid parameters", [invalid_gravity, invalid_payload]}} if
    parameters are not numbers / valid strings

  """
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

  @doc """
  Calculates fuel needed to land a payload mass in destination gravity.
  Usage: get_landing_fuel_for(destination, payload_mass)
  destination parameters can be a number or string "Earth", "Mars" or "Moon"
  payload_mass must be a sufficiently large number (formulas does not return positive fuel weight
  for small enough mass)

  Returns {:ok, fuel_load} for valid arguments.
  Returns {:error, :payload_to_light} if payload weight is to small to apply the formulas
  Returns {:error, {"Invalid parameters", [invalid_gravity, invalid_payload]}} if
    parameters are not numbers / valid strings

  """

  def get_landing_fuel_for(destination, payload_mass) do
    destination
    |> get_gravity_for()
    |> gross_landing_fuel_for(payload_mass)
    |> validate_fuel_load()
  end

  def gross_landing_fuel_for(destination_gravity, payload_mass)
      when is_number(destination_gravity) and
             is_number(payload_mass) do
    destination_gravity * payload_mass * 0.033 - 42
  end

  def gross_landing_fuel_for(invalid_gravity, invalid_payload) do
    # Logger.error("Invalid fuel parameters: Target gravity#{IO.inspect(invalid_gravity)}, Payload: #{IO.inspect(invalid_payload)}")
    {:error, {"Invalid landing parameters", [invalid_gravity, invalid_payload]}}
  end

  @doc """
  Calculates fuel needed to launch payload mass from origin and land it on destination (including launch of
   fuel needed for landing).
  Usage: get_total_fuel_for(origin, destination, payload_mass)
  origin and destination parameters can be numbers or strings "Earth", "Mars" or "Moon"
  payload_mass must be a sufficiently large number (formulas does not return positive fuel weight for small enough mass)

  Returns {:ok, fuel_load} for valid arguments.
  Returns {:error, :payload_to_light} if payload weight is to small to apply the formulas
  Returns {:error, {"Invalid parameters", [invalid_gravity_1, invalid_gravity_2, invalid_payload]}} if
    parameters are not numbers / valid strings

  """
  def get_total_fuel_for(origin, destination, payload_mass) do
    origin_gravity = get_gravity_for(origin)
    destination_gravity = get_gravity_for(destination)

    calculate_total_fuel_for(origin_gravity, destination_gravity, payload_mass)
  end

  def calculate_total_fuel_for(origin_gravity, destination_gravity, payload_mass)
      when is_number(origin_gravity) and
             is_number(destination_gravity) and
             is_number(payload_mass) do
    landing_fuel = gross_landing_fuel_for(destination_gravity, payload_mass)
    launch_fuel = gross_launch_fuel_for(origin_gravity, payload_mass + landing_fuel)

    with {:ok, _} <- validate_fuel_load(launch_fuel),
         {:ok, _} <- validate_fuel_load(landing_fuel) do
      {:ok, floor(launch_fuel + landing_fuel)}
    else
      error = {:error, _} -> error
    end
  end

  def calculate_total_fuel_for(invalid_gravity_1, invalid_gravity_2, invalid_payload) do
    # Logger.error("Invalid fuel parameters: #{IO.inspect(invalid_gravity_1)}, Target Gravity: #{IO.inspect(invalid_gravity_2)}, Payload: #{IO.inspect(invalid_payload)}")
    {:error, {"Invalid parameters", [invalid_gravity_1, invalid_gravity_2, invalid_payload]}}
  end

  def validate_fuel_load(load) do
    case load do
      error = {:error, _} -> error
      fuel_load when fuel_load > 1 -> {:ok, floor(fuel_load)}
      _ -> {:error, :payload_to_light}
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
