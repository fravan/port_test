-module(port_test_ffi).

-export([open_port_test/0, close_port_test/1]).

open_port_test() ->
    open_port({spawn_executable, os:find_executable("gleam")}, [{args, ["run"]}, {cd, "."}]).

close_port_test(Port) ->
    port_close(Port).
