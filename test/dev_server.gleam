import gleam/erlang/process
import gleam/io
import port_test

pub fn main() {
  let pid = process.start(port_test.main, False)
  io.debug(pid)
  process.sleep(10_000)

  io.println("Simulating new build, stopping and restarting process")
  process.kill(pid)
  process.sleep(5000)
  let new_pid = process.start(port_test.main, False)
  io.debug(new_pid)

  process.sleep_forever()
}
