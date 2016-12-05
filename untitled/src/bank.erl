%% @author ����������
%% @doc @todo Add description to bank.


-module(bank).

%% ====================================================================
%% API functions
%% ====================================================================
-export([main/0,getBalance/2]).

createClients(1) -> [spawn(fun() -> bankClient(1,3)end)];
createClients(NumClients) ->
	[spawn(fun() -> bankClient(NumClients,3)end)|createClients(NumClients-1)].

hasClient([H|[]], Deposit, Pin, Request) -> H ! {isClient, Deposit, Pin, Request, self()};
hasClient([H|T], Deposit, Pin, Request) ->
	H ! {isClient, Deposit, Pin, Request, self()},
	hasClient(T, Deposit, Pin, Request).

getClientBalance([H|[]], Deposit, Pin, Request) -> H ! {getBalance, Deposit, Pin, Request, self()};
getClientBalance([H|T], Deposit, Pin, Request) ->
	H ! {getBalance, Deposit, Pin, Request, self()},
	getClientBalance(T, Deposit, Pin, Request).

bank(Clients) when is_list(Clients) ->
  receive 
	{getClient, Deposit, Pin, Request, PID} ->
		hasClient(Clients, Deposit, Pin, Request); 
	{isClientAnsver, ClientId, Request, Ansver} ->
		io:format("Card ~w .~n",[Ansver]),
		erlang:element(1,Request) ! {getClientAnsver, self(), ClientId, Request};
	{getBalance, Deposit,Pin, Request, PID} ->
		getClientBalance(Clients, Deposit, Pin, Request); 
	{balanceAnsver, ClientId, Request, Ansver} ->
		io:format("Balance ~w .~n",[Ansver]),
		erlang:element(1,Request) ! {getAnsver, self(), Ansver}
  end,
	bank(Clients);
bank(NumClients) -> 
  Clients = createClients(NumClients),
  bank(Clients).


hasCard([], Deposit, Pin) -> false;
hasCard([{Deposit,_,_,_,_}|T], Deposit, Pin) -> true;
hasCard([H|T], Deposit, Pin) -> hasCard(T, Deposit, Pin).

balanceCard([], Deposit, Pin) -> 0;
balanceCard([{Deposit,_,_,Sum,_}|T], Deposit, Pin) -> Sum;
balanceCard([H|T], Deposit, Pin) -> hasCard(T, Deposit, Pin).


%% deposit, pin, date, sum, valuta
createCands(Id,1) -> [{1+Id,2+Id,3+Id,1+Id,eur}];
createCands(Id,N) ->
	[{2*N+Id,2*N+Id,3*N+Id,1*N+Id,eur}|createCands(Id,N-1)].
	
bankClient(Id,Cargs) when is_list(Cargs) ->
  receive 
	{isClient, Deposit, Pin, Request, PID} ->
		io:format("Card ~w.~n",[hasCard(Cargs, Deposit, Pin)]),
		PID ! {isClientAnsver, self(), Request, hasCard(Cargs, Deposit, Pin)};
	{getBalance, Deposit, Pin, Request, PID} ->
		io:format("Card ~w.~n",[hasCard(Cargs, Deposit, Pin)]),
		PID ! {balanceAnsver, self(), Request, balanceCard(Cargs, Deposit, Pin)};
	{getClientId, Deposit, Pin, Request, PID} ->
		PID ! {isClientAnsver, self(), Request, hasCard(Cargs, Deposit, Pin)} 
  end,
  bankClient(Id,Cargs);
bankClient(Id,N) ->
  Cards = createCands(Id,N), bankClient(Id,Cards).
%%getBalance(X) -> io:format("Client ~w.~n", [X]);
getBalance(Deposit,Pin) ->
	Bank = global:whereis_name(bank),
		Bank ! {getBalance, Deposit,Pin, {self(), Deposit,Pin}, self()},
  receive 
	{getAnsver, _,Ansver} ->
		Ansver 
  end.

main() ->
	Bank = spawn(fun() -> bank(1)end),
	global:register_name(bank,Bank),
	Bank ! {getClient, 7, 7, {self(), 7, 7}, self()},
	
  receive 
	{getClientAnsver, PID, ClientId, _} ->
		io:format("Client ~w.~n", [ClientId]) 
  end
.



%% ====================================================================
%% Internal functions
%% ====================================================================


