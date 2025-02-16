import gleam/bytes_tree
import gleam/erlang/process
import gleam/function
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import mist.{type Connection, type ResponseData}

pub fn main() {
  io.println("Launching new mist server on localhost:3000")

  let assert Ok(_) =
    fn(_req: Request(Connection)) -> Response(ResponseData) {
      io.println("A response came in")
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.from_string("Hello world")))
    }
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  listen(
    process.new_selector()
    |> process.selecting_anything(function.identity),
  )
}

fn listen(selector) {
  let msg = process.select_forever(selector)
  io.println("Server received the following message: ")
  io.debug(msg)
  listen(selector)
}
