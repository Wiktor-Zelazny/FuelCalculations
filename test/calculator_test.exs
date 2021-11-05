defmodule FuelCalculator.CalculatorTest do
  use ExUnit.Case
  alias FuelCalculator.Calculator

  describe "Launch calculation tests" do
    test "valid numerical values lead to valid launch load" do
      assert 537 = Calculator.get_launch_fuel_for(10, 1000)
    end

    test "To light launch payloads result in error" do
      assert {:error, :payload_to_light} = Calculator.get_launch_fuel_for(1.62, 486)
    end

    test "Nonsense launch input results in error" do
      assert {:error, _reason} = Calculator.get_launch_fuel_for("The Moon", "Me")
    end
  end

  describe "Landing calculation tests" do
    test "Apollo command module Earth landing" do
      assert 13447 == Calculator.get_landing_fuel_for(9.807, 28801)
    end

    test "To light landing payloads result in error" do
      assert {:error, :payload_to_light} = Calculator.get_landing_fuel_for(1.62, 786)
    end

    test "Nonsense landing input results in error" do
      assert {:error, _reason} = Calculator.get_landing_fuel_for("The Moon", "Me")
    end
  end

  describe "Travel tests" do
    test "for Apollo 11 travel" do
      assert 51898 ==
               Calculator.long_travel(28801, [
                 [:launch, 9.807],
                 [:land, 1.62],
                 [:launch, 1.62],
                 [:land, 9.807]
               ])
    end

    test "for mission to Mars" do
      assert 33388 ==
               Calculator.long_travel(14606, [
                 [:launch, 9.807],
                 [:land, 3.711],
                 [:launch, 3.711],
                 [:land, 9.807]
               ])
    end

    test "for passager ship" do
      assert 212_161 ==
               Calculator.long_travel(75432, [
                 [:launch, 9.807],
                 [:land, 1.62],
                 [:launch, 1.62],
                 [:land, 3.711],
                 [:launch, 3.711],
                 [:land, 9.807]
               ])
    end

    test "for error patches" do
      assert {:error, :invalid_arguments} ==
               Calculator.long_travel(:invalid_payload, [[:launch, 10]])

      assert {:error, :invalid_arguments} == Calculator.long_travel(100, {[:launch, 10]})
      assert {:error, :payload_to_light} == Calculator.long_travel(786, [[:land, 1.62]])
      assert {:error, :invalid_gravity} == Calculator.long_travel(78600, [[:land, -1.62]])
      assert {:error, :invalid_gravity} == Calculator.long_travel(78600, [[:land, "2Gs"]])
      assert {:error, :invalid_operation} == Calculator.long_travel(78600, [[:litfoff, 1.62]])
    end
  end
end
