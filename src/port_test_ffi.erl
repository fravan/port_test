-module(port_test_ffi).

-export([open_port_test/1, close_port_test/1, kill_port_test/1]).

% erl -eval port_test@@main:run(port_test) -noshell
open_port_test(Args) ->
    Args_ = lists:map(fun(Arg) -> binary_to_list(Arg) end, Args),
    open_port({spawn_executable, os:find_executable("erl")}, [{args, Args_}, {cd, "."}]).

    % open_port({spawn_executable, os:find_executable("gleam")}, [{args, ["run"]}, {cd, "."}]).

close_port_test(Port) ->
    port_close(Port).

kill_port_test(Port) ->
    exit(Port, normal).
