import gleam/erlang/process
import mist
import port_test/router

pub fn main() {
  let assert Ok(_) =
    router.handle_request
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}
