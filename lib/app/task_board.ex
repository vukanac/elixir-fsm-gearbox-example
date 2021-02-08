defmodule App.TaskBoard do # TaskService

  alias App.Task
  alias App.TaskMachine

  def create_task(_user, %{} = data) do
    # Not needed as %Task.status default value is hardcoded.
    # initial_status = TaskMachine.__machine_states__(:initial)
    data =
      data
      |> convert_valid_properties(Task)
      # |> Map.put(:status, initial_status)

    {:ok, struct(Task, data)}
    # on (validation, db) errors
    # {:error, "some error"}
  end

  defp convert_valid_properties(%{} = string_map, target) do
    # alias: cast
    keys =
      struct(target)
      |> Map.keys()
      |> List.delete(:__struct__)

    Enum.reduce(keys, %{}, fn key, acc ->
      Map.put(acc, key, string_map[Atom.to_string(key)])
    end)
  end

  def start_doing_task(_user, task) do
    # ...
    # {:ok, task} = db.find(task)
    # Your payment logic
    {:ok, updated_task} = Gearbox.transition(task, TaskMachine, "in_progress")
    # ...
    # :ok = db.update(task)
    # ...
    {:ok, updated_task}
    #
    # on any validation or db errors
    # {:error, "some error"}
  end

  def present_task(_user, task) do
    # same story, get, validate, update, store
    with \
      {:ok, updated_task} <- change_state(task, "review")
      # updated_task <- Map.put(updated_task, :updated_at, DateTime.now!("Etc/UTC"))
    do
      {:ok, updated_task}
    else
      {:error, "Cannot transition from `todo` to `review`"} ->
        {:error,  "first work on it"}

      :error ->
        {:error, "ended with unknown error"}

      error ->
        # should not be propagated
        error
    end
  end

  def complete_task(user, task) do
    # or finish
    # same story, get, validate, update, store
    {:ok, updated_task} = Gearbox.transition(task, TaskMachine, "done")
    # ...
    {:ok, updated_task}
  end

  defp change_state(task, to) do
    Gearbox.transition(task, TaskMachine, to)
  end
end
