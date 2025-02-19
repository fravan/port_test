import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import port_test
import shellout

// From gleam-radiate
type Module

type What

@external(erlang, "code", "modified_modules")
fn modified_modules() -> List(Module)

@external(erlang, "code", "purge")
fn purge(module: Module) -> Bool

@external(erlang, "code", "atomic_load")
fn atomic_load(modules: List(Module)) -> Result(Nil, List(#(Module, What)))

pub fn main() {
  let pid = process.start(port_test.main, False)
  io.debug(pid)
  process.sleep(10_000)

  io.println("Simulating new build")
  let build_result =
    shellout.command(run: "gleam", with: ["build"], in: ".", opt: [])
  case build_result {
    Ok(output) -> {
      io.println("Output of gleam build is the following:")
      io.debug(output)

      let mods = modified_modules()
      io.println("Modified modules:")
      io.debug(mods)
      list.each(mods, purge)
      let load = atomic_load(mods)
      io.println("Atomic load:")
      let _ = io.debug(load)
      Nil
    }
    Error(#(status, message)) -> {
      io.println_error(message)
      io.println_error(int.to_string(status))
      Nil
    }
  }

  process.sleep_forever()
}
