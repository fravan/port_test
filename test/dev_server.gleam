import gleam/bit_array
import gleam/dynamic
import gleam/dynamic/decode
import gleam/erlang
import gleam/erlang/charlist
import gleam/erlang/port.{type Port}
import gleam/erlang/process
import gleam/function
import gleam/io
import gleam/list
import gleam/result
import gleam/string

@external(erlang, "port_test_ffi", "open_port_test")
fn open_port(args: List(String)) -> Port

@external(erlang, "port_test_ffi", "close_port_test")
fn close_port(port: Port) -> Bool

@external(erlang, "port_test_ffi", "kill_port_test")
fn kill_port(port: Port) -> Bool

fn get_ebin(folder_name: String) -> String {
  "-pa /var/home/bazzite/Dev/port_test/build/dev/erlang/"
  <> folder_name
  <> "/ebin"
}

fn get_args() {
  [
    get_ebin("gleam_version"),
    get_ebin("gleam_stdlib"),
    get_ebin("gleam_crypto"),
    get_ebin("gleam_erlang"),
    get_ebin("gleam_http"),
    get_ebin("gleam_otp"),
    get_ebin("gleam_yielder"),
    get_ebin("gleeunit"),
    get_ebin("glisten"),
    get_ebin("gramps"),
    get_ebin("hpack"),
    get_ebin("logging"),
    get_ebin("mist"),
    get_ebin("port_test"),
    get_ebin("telemetry"),
    "-eval port_test@@main:run(port_test)",
    "-noshell",
  ]
}

fn get_cmd() {
  let args = get_args()
  list.fold(args, "erl", fn(cmd, arg) { cmd <> " " <> arg })
}

pub fn main() {
  // io.println(get_cmd())
  open_server()
}

type PortMessages {
  Data(String)
  Unknown(#(dynamic.Dynamic, List(decode.DecodeError)))
}

fn open_server() {
  io.println("Opening port…")
  let port = open_port(get_args())
  io.debug(port)
  let selector =
    process.new_selector()
    |> process.selecting_anything(fn(msg) {
      let decoder = {
        use message <- decode.subfield(
          [1, 1],
          decode.new_primitive_decoder("Data", fn(dyn) {
            decode.run(
              dyn,
              decode.list(decode.int)
                |> decode.map(fn(a) {
                  string.from_utf_codepoints(
                    list.map(a, string.utf_codepoint) |> result.values,
                  )
                }),
            )
            |> result.map_error(fn(_) { "Failed" })
          }),
        )
        // decode.list(decode.int))
        decode.success(message)
      }
      case decode.run(msg, decoder) {
        Ok(d) -> {
          // let assert Ok(d) = bit_array.to_string(bit)
          Data(d)
        }
        // Ok(Ok(decoded)) -> Data(decoded)
        // Ok(Error(Nil)) -> Data("lost")
        Error(err) -> Unknown(#(msg, err))
      }
    })

  listen_to_port_messages(selector)
  process.sleep(500)
  io.println("Closing port…")
  let result = close_port(port)
  io.debug(result)
  io.println("Killing port…")
  kill_port(port)
  io.println("Everything down, shutting down…")
}

fn listen_to_port_messages(selector) {
  case process.select(selector, 5000) {
    Ok(Data(message)) -> {
      io.println("From server:")
      io.debug(message)
      listen_to_port_messages(selector)
    }
    Ok(Unknown(errors)) -> {
      io.println("From server, unknown:")
      io.debug(errors)
      listen_to_port_messages(selector)
    }
    Error(_) -> {
      io.println("The process got nothing back")
    }
  }
}
