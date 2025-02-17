import gleam/erlang
import gleam/erlang/process
import gleam/function
import gleam/int
import gleam/io
import gleam/otp/actor
import gleam/otp/supervisor

pub fn main() {
  io.println("Starting new supervisor")

  let work_a = start_worker("Andre")
  let work_b = start_worker("Bill")

  let children = fn(children) {
    children
    |> supervisor.add(work_a)
    |> supervisor.add(work_b)
  }

  let assert Ok(super) =
    supervisor.start_spec(supervisor.Spec(
      argument: Nil,
      frequency_period: 1,
      max_frequency: 5,
      init: children,
    ))

  process.link(process.subject_owner(super))
  process.sleep_forever()
}

type WorkerState {
  WorkerState(process.Subject(WorkerMsg), Int)
}

type WorkerMsg {
  Work
}

fn start_worker(name: String) {
  supervisor.worker(fn(_) {
    actor.start_spec(
      actor.Spec(
        init_timeout: 500,
        init: fn() {
          let subject = process.new_subject()
          let _ = process.send_after(subject, 500, Work)

          actor.Ready(
            WorkerState(subject, 5 + int.random(10)),
            process.new_selector()
              |> process.selecting(subject, function.identity),
          )
        },
        loop: fn(msg, state) {
          let proc = erlang.format(process.self())
          let full_name = name <> " (" <> proc <> ")"
          case msg, state {
            Work, WorkerState(_, 0) -> {
              io.println(
                full_name <> " has finished working, and will now crash",
              )
              panic
            }
            Work, WorkerState(subject, count) -> {
              io.println(
                full_name <> " is working hard… " <> int.to_string(count),
              )
              let _ = process.send_after(subject, 300 + int.random(1000), Work)
              actor.continue(WorkerState(subject, count - 1))
            }
          }
        },
      ),
    )
  })
}
