# SensorSimulator
#
# This Elixir module simulates sensor data to demonstrate the use of Erlang Term Storage (ETS).
# It continuously generates temperature readings, stores them in ETS, and analyzes the temperature trends.
# Great for learning ETS in Elixir and understanding data handling in concurrent environments.
#
# Usage: Run the module to start the sensor simulation and temperature trend analysis.

defmodule SensorSimulator do
  use GenServer

  @max_entries 500000  # Approximate to manage memory usage
  @cleanup_interval 1000  # Milliseconds


  # Starts the GenServer
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Initializes the ETS table and starts the sensor simulation
  def init(:ok) do
    # Use `:named_table` to allow access from other processes
    :ets.new(:sensor_data, [:set, :public, :named_table])
    schedule_sensor_read()
    schedule_cleanup()
    {:ok, %{}}
  end

  # Schedules sensor readings
  defp schedule_sensor_read do
    Process.send_after(self(), :read_sensor, 1)
  end

  # Schedules ETS cleanup
  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval)
  end

  # Handles sensor readings
  def handle_info(:read_sensor, state) do
    current_time = System.os_time(:millisecond)
    true_temp = calculate_true_temp(current_time)
    simulated_temp = simulate_sensor_reading(true_temp)
    :ets.insert(:sensor_data, {current_time, simulated_temp})
    schedule_sensor_read()
    {:noreply, state}
   
  end



  # Handles ETS cleanup
  def handle_info(:cleanup, state) do
    cleanup_ets()
    schedule_cleanup()
    {:noreply, state}
  end

  # Cleans up old entries in ETS to manage memory
  defp cleanup_ets do
    current_size = :ets.info(:sensor_data, :size)
    if current_size > @max_entries do
      oldest_allowed_time = System.os_time(:millisecond) - @max_entries
      :ets.select_delete(:sensor_data, [{{:"$1", :"$2"}, [{:<, :"$1", oldest_allowed_time}], [true]}])
    end
  end

  # Calculates the true temperature
  defp calculate_true_temp(time) do
    # 5 minutes sine wave for a day
    amplitude = 10.0
    day_period = 5 * 60 * 1000
    base_temp = 20.0
    base_temp + amplitude * :math.sin(2 * :math.pi * time / day_period)
  end

  # Simulates a sensor reading with ±15% variance
  defp simulate_sensor_reading(true_temp) do
    variance = :rand.uniform() * 0.15 * true_temp
    if :rand.uniform() > 0.5, do: true_temp + variance, else: true_temp - variance
  end

  # Public function to start the analysis process
  def start_analysis do
     # Use `spawn` instead of `spawn_link` to avoid linking the process
     spawn(fn -> analyze_temperature() end)
  end

  # Periodically analyze temperature data
  defp analyze_temperature do
    analyze_and_report()
    :timer.sleep(10_000)  # Use :timer.sleep for more reliable behavior
    analyze_temperature()
  end

  # Analyzes and reports the temperature trend
  defp analyze_and_report do
    current_time = System.os_time(:millisecond)
    past_5_min_readings = readings_in_last(5 * 60 * 1000, current_time)
   
    current_avg = average_temperature(past_5_min_readings)

    past_15_sec_readings = readings_in_last(15_000, current_time)
    current_15_sec_avg = average_temperature(past_15_sec_readings)

    one_min_ago_readings = readings_in_last(15_000, current_time - 60_000)
    one_min_ago_avg = average_temperature(one_min_ago_readings)

    trend = if current_15_sec_avg > one_min_ago_avg, do: "rising", else: "falling"
    if Enum.count(past_5_min_readings) > 0, do: IO.puts("Past 5 min readings count: #{Enum.count(past_5_min_readings)}. Average temp (last 5 min): #{current_avg}, Trend: #{trend}")
  end

  # Fetches readings from the last specified milliseconds
  defp readings_in_last(milliseconds, current_time) do
    readings = :ets.tab2list(:sensor_data)
                  |> Enum.filter(fn {time, _temp} -> time >= current_time - milliseconds end)
    readings
  end

  # Calculates the average temperature
  defp average_temperature(readings) do
    count = Enum.count(readings)
    if count > 0 do
      Enum.sum(Enum.map(readings, fn {_time, temp} -> temp end)) / count
    else
      nil  # Or some default value if no readings are available
    end
  end
end

# Starting the server and the analysis process
IO.puts ("       _(   '`.   _\\x/__")
IO.puts ("  .=(`(    .   )   /X\\        CLOUD COMPUTING")
IO.puts ("---- Welcome to Cloud Computing: Elixir Edition. ---- ")
IO.puts ("This program simulates a day's temperature fluctuations every 5 minutes.")
IO.puts ("- Temperatures are collected continuously from simulated sensors")
IO.puts ("- sensors deviate +/- 15% from the true temperature.")
IO.puts ("- Every 10 seconds, an analysis process analyzes the temperatures.")
{:ok, _pid} = SensorSimulator.start_link([])
SensorSimulator.start_analysis()

# Prevent the script from exiting immediately
Process.sleep(:infinity)