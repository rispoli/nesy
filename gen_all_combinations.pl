:- [gen_traces].

gen_all_combinations(Length, NRules, Observations, Output) :-
    rule_placeholder(NRules, Rules_Placeholder),
    io_layer(Rules_Placeholder, Observations, IO_layer, _),
    findall(Trace, trace_perm(Length, Observations, Trace), Traces),
    tell(Output),
    maplist(print_trace(IO_layer), Traces),
    told.

print_trace(IO_layer, Trace) :-
    print_trace(Trace, IO_layer, 'trace = [').

trace_perm(0, _, []) :- !.
trace_perm(N, Observations, [P | T]) :-
    perm(Observations, P),
    N_ is N - 1,
    trace_perm(N_, Observations, T).

perm([], []).
perm([H | T], [-H | T_]) :-
    perm(T, T_).
perm([H | T], [H | T_]) :-
    perm(T, T_).
