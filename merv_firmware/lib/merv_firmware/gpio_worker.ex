defmodule MervFirmware.GPIOWorker do
  use GenServer

  alias ElixirALE.GPIO

  require Logger

  defmodule State do
    defstruct input_pid: nil, output_pid: nil, led_on: false
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    input_pin = Application.get_env(:merv_firmware, :input_pin)
    output_pin = Application.get_env(:merv_firmware, :output_pin)

    {:ok, input_pid} = GPIO.start_link(input_pin, :input)
    {:ok, output_pid} = GPIO.start_link(output_pin, :output)

    GPIO.set_int(input_pid, :both)
    :erlang.send_after(500, self(), :toggle_led)

    led_off(output_pid)

    {
      :ok,
      %State{
        input_pid: input_pid,
        output_pid: output_pid,
        led_on: false
      }
    }
  end

  def handle_info({:gpio_interrupt, p, :rising}, state) do
    Logger.debug("Received rising event on pin #{p}")
    {:noreply, state}
  end

  def handle_info({:gpio_interrupt, p, :falling}, state) do
    Logger.debug("Received falling event on pin #{p}")
    {:noreply, state}
  end

  def handle_info(:toggle_led, state) do
    state_out = toggle_led(state)
    :erlang.send_after(500, self(), :toggle_led)
    {:noreply, state_out}
  end

  defp toggle_led(state = %State{led_on: false, output_pid: pid}) do
    led_on(pid)
    %{state | led_on: true}
  end

  defp toggle_led(state = %State{led_on: true, output_pid: pid}) do
    led_off(pid)
    %{state | led_on: false}
  end

  defp led_off(pid) do
    Logger.debug("Turning LED off")
    GPIO.write(pid, 0)
  end

  defp led_on(pid) do
    Logger.debug("Turning LED on")
    GPIO.write(pid, 1)
  end
end
