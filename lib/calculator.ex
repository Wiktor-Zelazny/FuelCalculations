defmodule FuelCalculator.Calculator do
  @doc """
  Calculates fuel needed for series of launches and landings.
  Usage: long_travel(payload, ops_list) where ops list consists of [:operation, gravity] pairs.

  Returns total fuel needed for the operations.
  Returns {:error, invalid_arguments} for valid arguments.
  Returns {:error, :payload_to_light} if payload is not a number or if ops_list is not a list
  Returns {:error, :invalid_gravity} if one of gravities is not a positive integer
  Returns {:error, :invalid_operation} if one of operations is not :launch ot :land
  In case of multiple errors the first error encountered is returned

    parameters are not numbers / valid strings

  """
  def long_travel(payload, ops_list) when is_number(payload) and is_list(ops_list) do
    ops_list
    |> Enum.reverse()
    |> Enum.reduce(
      0,
      fn [operation, gravity], acc -> try_adding_fuel(payload, operation, gravity, acc) end
    )
  end

  def long_travel(_payload, _ops_list), do: {:error, :invalid_arguments}

  defp try_adding_fuel(payload, operation, gravity, acc)
       when is_number(acc) and is_number(gravity) and gravity > 0 do
    needed_fuel_or_error =
      case operation do
        :launch -> get_launch_fuel_for(gravity, acc + payload)
        :land -> get_landing_fuel_for(gravity, acc + payload)
        _ -> {:error, :invalid_operation}
      end

    case needed_fuel_or_error do
      fuel when is_number(fuel) -> acc + fuel
      error = {:error, _} -> error
    end
  end

  defp try_adding_fuel(_payload, _operation, gravity, acc) do
    if(is_number(gravity) and gravity > 0) do
      acc
    else
      {:error, :invalid_gravity}
    end
  end

  @doc """
  Calculates fuel needed to launch a payload mass from origin gravity.
  Usage: get_launch_fuel_for(origin, payload_mass)
  origin can be a number or string "Earth", "Mars" or "Moon"
  payload_mass must be a sufficiently large number (formulas does not return positive fuel weight
  for small enough mass)

  Returns {:ok, fuel_load} for valid arguments.
  Returns {:error, :payload_to_light} if payload weight is to small to apply the formulas
  Returns {:error, {"Invalid parameters", [invalid_gravity, invalid_payload]}} if
    parameters are not numbers / valid strings (this should never happen when it's called
    by long_travelled function)

  """
  def get_launch_fuel_for(origin, payload_mass) do
    origin
    |> gross_launch_fuel_for(payload_mass)
    |> validate_fuel_load()
  end

  defp gross_launch_fuel_for(origin_gravity, payload_mass)
       when is_number(origin_gravity) and
              is_number(payload_mass) do
    load = floor(origin_gravity * payload_mass * 0.042 - 33)

    if load > 0 do
      load + gross_launch_fuel_for(origin_gravity, load)
    else
      0
    end
  end

  defp gross_launch_fuel_for(invalid_gravity, invalid_payload) do
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
    |> gross_landing_fuel_for(payload_mass)
    |> validate_fuel_load()
  end

  defp gross_landing_fuel_for(destination_gravity, payload_mass)
       when is_number(destination_gravity) and
              is_number(payload_mass) do
    load = floor(destination_gravity * payload_mass * 0.033 - 42)

    if load > 0 do
      load + gross_landing_fuel_for(destination_gravity, load)
    else
      0
    end
  end

  defp gross_landing_fuel_for(invalid_gravity, invalid_payload) do
    # Logger.error("Invalid fuel parameters: Target gravity#{IO.inspect(invalid_gravity)}, Payload: #{IO.inspect(invalid_payload)}")
    {:error, {"Invalid landing parameters", [invalid_gravity, invalid_payload]}}
  end

  defp validate_fuel_load(load) do
    case(load) do
      error = {:error, _} -> error
      fuel_load when fuel_load > 0 -> fuel_load
      _ -> {:error, :payload_to_light}
    end
  end
end
