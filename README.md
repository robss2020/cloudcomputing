# Elixir Cloud Computing with ETS

This short simulation program is designed for people new to Elixir programming.
It uses Erlang Term Storage (ETS), Elixir's powerful in-memory storage system.

>ETS allows for high-performance data storage and retrieval, making it a go-to for handling large amounts of data quickly.

## Elixir Cloud Computing Simulates Temperature Sensors
A small and practical way to understand ETS.

It simulates sensor data (think temperature readings) that fluctuate in a sine wave pattern, mimicking real-world sensor behavior.

This chatty sensor creates a large volume of data, which is then stored in ETS.

The program includes a GenServer. In another process, the program reads the sensor data and calculates the average temperature over the last few minutes, determining whether the temperature is rising or falling.

## Play, Tweak, Learn!

Play around with the program! Change the sensor's data generation rate, alter the analysis logic, or experiment with the ETS table's properties.

It's a safe and fun way to learn more about ETS and Elixir's concurrency model.

## Starting the program

Start the program with `elixir cloudcomputing.exs`.  It will start and begin to produce and analyze data.  Exit it with ctrl-c.

## Ready to help someone learn more Elixir?
The author Robert Viragh is looking for a position as an Elixir and Phoenix developer, if you have an opening feel free to reach out: rviragh at gmail.com

## License

This project is released into the public domain, without any warranty.  Use it however you want commercially or noncommercially, without attribution.
For more information, please refer to <https://unlicense.org>