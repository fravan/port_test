import gleam/dynamic
import gleam/erlang/process
import gleam/io

@external(erlang, "port_test_ffi", "open_port_test")
fn open_port() -> dynamic.Dynamic

@external(erlang, "port_test_ffi", "close_port_test")
fn close_port(port: dynamic.Dynamic) -> Bool

pub fn main() {
  io.println("Opening port…")
  let port = open_port()
  io.debug(port)
  process.sleep(500)
  io.println("Closing port…")
  let result = close_port(port)
  io.debug(result)
}
