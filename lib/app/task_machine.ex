defmodule App.TaskMachine do
  use Gearbox,
    field: :status, # used to retrieve the state of the given struct. Defaults to `:state`
    states: ~w(todo in_progress review done), # list of finite states in the state machine
    # initial: "todo", # initial state of the struct, if struct has `nil` state to begin with. Defaults to the first item of `:states`
    transitions: %{
      "todo" => ~w(in_progress done),
      "in_progress" => "review",
      "review" => "done",
    } # a map of possible transitions from `current_state` to `next_state`. `*` wildcard is allowed to indicate any states.
end
