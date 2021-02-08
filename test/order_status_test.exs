defmodule App.OrderStatusTest do
  use ExUnit.Case

  alias App.Task
  alias App.Order
  alias App.OrderMachine
  alias App.OrderService

  test "Task has initial status as hardcoded default struct value" do
    # problem is we have to sync two places
    task = %Task{}

    assert "todo" = task.status
  end

  test "Order has no initial value in status which is equivalent to nil" do
    order = %Order{}
    assert nil == order.status
  end

  test "Set Order status initial value manually, hardcoded in service" do
    # The problem is we have to sync two places.
    # The good is we don't couple state machine with Order struct.
    assert %Order{
      status: "pending_payment"
    } = OrderService.create_order_hardcoded(%{})
  end

  test "Set Order initial status on creation with its value in one place" do
    # This is a nice solution as it has initial state in one place.
    # Also, we could directly, in the struct, set default value for status,
    # but that would couple machine with Order struct without need.
    initial_status = OrderMachine.__machine_states__(:initial)

    assert "pending_payment" == initial_status

    assert %Order{status: "pending_payment"} = OrderService.create_order(%{})
  end

  test "should return :error on first transition to initial status" do
    order = %Order{}
    assert nil == order.status

    # machine has initial: "pending_payment"
    result = Gearbox.transition(order, OrderMachine, "pending_payment")

    assert {:error, message} = result
    assert message =~ "Cannot transition from `pending_payment`"
  end

  test "should return error for transition from status A to the same A" do
    from = "paid"
    to = "paid"
    order = %Order{status: from}
    result = Gearbox.transition(order, OrderMachine, to)

    assert {:error, message} = result
    assert message =~ "Cannot transition from `paid` to `paid"
  end

  test "should return error for invalid states" do
    # Because of this Order status should not be set directly manually.
    # Should we still attach machine to struct with transition functions?
    # It looks valid for simple case, but in most case some other calculation
    # will be involved which will happen in OrderService.
    from = "invalid"
    to = "other_invalid"
    order = %Order{status: from}
    result = Gearbox.transition(order, OrderMachine, to)

    assert {:error, message} = result
    assert message =~ "Cannot transition from `#{from}` to `#{to}`"
  end

  test "OrderService should initialize and run steps until canceled" do
    # from: pending_payment
    order = OrderService.create_order(%{})
    steps = ["cancelled"] # watch out for US vs. GB variants

    cancelled = Enum.reduce(steps, {:ok, order}, fn to, {:ok, current} ->
      Gearbox.transition(current, OrderMachine, to)
    end)

    assert {:ok, %Order{status: "cancelled"}} = cancelled
  end

  test "OrderService should initialize and run steps until refunded" do
    # from: pending_payment
    order = OrderService.create_order(%{})
    steps = ["paid", "refunded"]

    refunded = Enum.reduce(steps, {:ok, order}, fn to, {:ok, current} ->
      Gearbox.transition(current, OrderMachine, to)
    end)

    assert {:ok, %Order{status: "refunded"}} = refunded
  end

  test "OrderService should initialize and run steps until fulfilled" do
    # from: pending_payment
    order = OrderService.create_order(%{})
    steps = ["paid", "pending_collection", "fulfilled"]

    fulfilled = Enum.reduce(steps, {:ok, order}, fn to, {:ok, current} ->
      Gearbox.transition(current, OrderMachine, to)
    end)

    assert {:ok, %Order{status: "fulfilled"}} = fulfilled
  end

  test "should return :error if direct transition to not allowed" do
    # from: pending_payment
    order = OrderService.create_order(%{})
    to = "fulfilled"

    result = Gearbox.transition(order, OrderMachine, to)

    assert {:error, message} = result
    assert message =~ "Cannot transition from `pending_payment` to `#{to}`"
  end

  test "The Commerce service/OrderService is used to mark Order to Payed" do
    user = "me"
    # probably stored in DB
    # probably result would be just :ok | {:error, any()}
    order = OrderService.create_order(%{})
    #
    # fetch task from DB, update status, store it back updated
    # probably result would be just :ok | {:error, any()}
    paid_order = OrderService.pay(user, order)

    assert {:ok, %Order{status: "paid"}} = paid_order
  end
end
