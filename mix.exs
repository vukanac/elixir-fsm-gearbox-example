defmodule FsmGearboxExample.MixProject do
  use Mix.Project

  def project do
    [
      app: :fsm_gearbox_example,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:gearbox, "~> 0.3.1"}
    ]
  end
end
