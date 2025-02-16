import gleam/bytes_tree
import gleam/erlang/process
import gleam/function
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import mist.{type Connection, type ResponseData}

pub fn main() {
  io.println("Launching new mist server on localhost:3000")

  let assert Ok(mist_subject) =
    fn(_req: Request(Connection)) -> Response(ResponseData) {
      io.println("A request came in")
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.from_string("Hello world")))
    }
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  let mist_pid = process.subject_owner(mist_subject)
  io.debug(process.self())
  io.debug(mist_pid)
  let got_linked = process.link(mist_pid)
  io.debug(got_linked)

  process.sleep_forever()
}

fn listen(selector) {
  let msg = process.select_forever(selector)
  io.println("Server received the following message: ")
  io.debug(msg)
  listen(selector)
}
