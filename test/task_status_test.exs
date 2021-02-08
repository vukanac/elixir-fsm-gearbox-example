defmodule App.TaskStatusTest do
  use ExUnit.Case

  alias App.Task
  alias App.TaskBoard # is in this case a TaskService

  test "should successfully complete all transitions" do
    user = "me"

    # probably stored in DB
    # probably result would be just :ok | {:error, any()}
    assert {:ok, task} = TaskBoard.create_task(user, %{
      "title" => "fix something"
    })
    assert %Task{status: "todo", title: "fix something"} = task

    # fetch task from DB, update status, store it back updated
    # probably result would be just :ok | {:error, any()}
    assert {:ok, started_task}  = TaskBoard.start_doing_task(user, task)
    assert %Task{status: "in_progress"} = started_task

    # fetch task from DB, update status, store it back updated
    # probably result would be just :ok | {:error, any()}
    assert {:ok, review}  = TaskBoard.present_task(user, started_task)
    assert %Task{status: "review"} = review

    assert {:ok, finished}  = TaskBoard.complete_task(user, review)
    assert %Task{status: "done"} = finished
  end

  test "should return :error if a task goes directly to review" do
    user = "me"

    # probably stored in DB
    # probably result would be just :ok | {:error, any()}
    assert {:ok, task} = TaskBoard.create_task(user, %{})
    assert %Task{status: "todo"} = task

    # try to move to Review
    assert {:error, "first work on it"}  = TaskBoard.present_task(user, task)
  end
end
