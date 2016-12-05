%%%-------------------------------------------------------------------
%%% @author Admin
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Нояб. 2016 20:20
%%%-------------------------------------------------------------------
-module(zaglushka).
-export([funA/2]).
funA(A, V)-> erlang:set_cookie(node(),'dssfsf'), A.


%% API

