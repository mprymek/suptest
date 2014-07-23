defmodule Crasher do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    IO.puts "Crasher starting..."
    send(self,:crash)
    {:ok,nil}
  end

  def handle_info(:crash,state) do
    IO.puts "Crasher crashing..."

    IO.puts(1/0)

    # never reached...
    {:noreply,state}
  end

end


defmodule SuptestTest do
  use ExUnit.Case
  import Supervisor.Spec, warn: false

  test "first test" do

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Suptest.Worker, [arg1, arg2, arg3])
      worker(Crasher,[]),
    ]

    IO.puts "Supervisor starting..."

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Suptest.Supervisor]
    Supervisor.start_link(children, opts)

    # catch supervisor crash...
    Process.flag(:trap_exit, true)

    # wait for Crasher to come up
    receive do
      {:EXIT, pid, reason} ->
        IO.puts "Process #{inspect pid} exited with reason #{inspect reason}"
    after 5000 -> IO.puts "Timeout!"
    end
  end
end
