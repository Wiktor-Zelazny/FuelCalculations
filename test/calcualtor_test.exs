defmodule FuelCalculator.CalculatorTest do
  use ExUnit.Case
  alias FuelCalculator.Calculator

  describe "Launch calculation tests" do
    test "valid numerical values lead to valid launch load" do
      assert {:ok, 387} = Calculator.get_launch_fuel_for(10, 1000)
    end

    test "valid string value leads to valid launch load" do
      assert {:ok, 378} = Calculator.get_launch_fuel_for("Earth", 1000)
    end

    test "To light launch payloads result in error" do
      assert {:error, :payload_to_light} = Calculator.get_launch_fuel_for("Moon", 486)
    end

    test "Nonsense launch input results in error" do
      assert {:error, reason} = Calculator.get_launch_fuel_for("The Moon", "Me")
    end
  end

  describe "Landing calculation tests" do
    test "valid numerical values lead to valid landing load" do
      assert {:ok, 288} = Calculator.get_landing_fuel_for(10, 1000)
    end

    test "valid string value leads to valid landing load" do
      assert {:ok, 281} = Calculator.get_landing_fuel_for("Earth", 1000)
    end

    test "To light landing payloads result in error" do
      assert {:error, :payload_to_light} = Calculator.get_landing_fuel_for("Moon", 786)
    end

    test "Nonsense landing input results in error" do
      assert {:error, reason} = Calculator.get_landing_fuel_for("The Moon", "Me")
    end
  end

  describe "One-way journey calculation tests" do
    test "valid numerical values lead to valid results" do
      assert {:ok, 795} = Calculator.get_total_fuel_for(10, 10, 1000)
    end

    test "valid string values lead to valid results" do
      assert {:ok, 492} = Calculator.get_total_fuel_for("Earth", "Mars", 1000)
    end

    test "fuel needed to launch fuel for landing is included" do
      {:ok, landing_fuel} = Calculator.get_landing_fuel_for("Mars", 1000)
      {:ok, launch_fuel} = Calculator.get_launch_fuel_for("Earth", 1000 + landing_fuel)
      {:ok, total_fuel} = Calculator.get_total_fuel_for("Earth", "Mars", 1000)

      rounded_difference = total_fuel - landing_fuel - launch_fuel
      assert rounded_difference in [0, 1]
    end

    test "To light payloads results in error" do
      assert {:error, :payload_to_light} = Calculator.get_total_fuel_for("Moon", "Moon", 800)
    end

    test "Nonsense input results in error" do
      assert {:error, reason} = Calculator.get_total_fuel_for("I", "Like", "Elixir")
    end
  end
end
