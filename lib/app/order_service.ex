defmodule App.OrderService do # Commerce

  alias App.Order
  alias App.OrderMachine

  def create_order_hardcoded(%{} = data) do
    data = Map.put(data, :status, "pending_payment")
    struct(Order, data)
  end

  def create_order(%{} = data) do
    initial_status = OrderMachine.__machine_states__(:initial)
    data = Map.put(data, :status, initial_status)
    struct(Order, data)
  end

  def pay(_user, order) do
    # ...
    # {:ok, order} = db.find(order)
    # Your payment logic
    {:ok, updated_task} = Gearbox.transition(order, OrderMachine, "paid")
    # ...
    # :ok = db.update(order)
    # ...
  end
end
