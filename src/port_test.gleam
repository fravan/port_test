import gleam/erlang/process
import gleam/function
import gleam/int
import gleam/io
import gleam/otp/actor
import gleam/otp/supervisor
import gleam/string
import repeatedly

pub fn main() {
  let pid = spawn_supervisor()

  process.sleep(2500)

  process.kill(pid)
  io.println("Killed pid " <> string.inspect(pid))
  process.sleep_forever()
}

fn spawn_supervisor() {
  process.start(
    fn() {
      let children = fn(children) {
        children
        |> supervisor.add(start_worker())
      }
      supervisor.start_spec(supervisor.Spec(
        argument: Nil,
        frequency_period: 1,
        max_frequency: 5,
        init: children,
      ))
    },
    True,
  )
}

type Work {
  Work(Int)
}

fn start_worker() {
  supervisor.worker(fn(_) {
    actor.start_spec(
      actor.Spec(
        init_timeout: 500,
        init: fn() {
          let subject = process.new_subject()
          let repeater =
            repeatedly.call(500, Nil, fn(_state, i) {
              process.send(subject, Work(i))
            })

          actor.Ready(
            repeater,
            process.new_selector()
              |> process.selecting(subject, function.identity),
          )
        },
        loop: fn(msg, state) {
          case msg {
            Work(count) -> {
              io.println("Working " <> int.to_string(count))
              actor.continue(state)
            }
          }
        },
      ),
    )
  })
}
