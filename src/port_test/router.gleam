import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import mist.{type Connection, type ResponseData}

pub fn handle_request(_req: Request(Connection)) -> Response(ResponseData) {
  io.println("A request came out")
  response.new(200)
  |> response.set_body(mist.Bytes(bytes_tree.from_string("Hello world!")))
}
