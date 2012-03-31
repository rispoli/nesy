:- [nn2m].

gen_traces(HowMany, Length, NRules, Observations, Output) :-
    rule_placeholder(NRules, Rules_Placeholder),
    io_layer(Rules_Placeholder, Observations, IO_layer, _),
    tell(Output),
    print_n_traces(HowMany, Length, IO_layer, Observations),
    told.

rule_placeholder(0, []) :- !.
rule_placeholder(N, [r(_) | Ps]) :-
    N_ is N - 1, rule_placeholder(N_, Ps).

print_n_traces(0, _, _, _) :- !.
print_n_traces(HowMany, Length, IO_layer, Observations) :-
    gen_trace_of_length(Length, Observations, Trace),
    print_trace(Trace, IO_layer, 'trace = ['),
    HowMany_ is HowMany - 1,
    print_n_traces(HowMany_, Length, IO_layer, Observations).

gen_trace_of_length(0, _, []) :- !.
gen_trace_of_length(Length, Observations, [Rand_Ob | Output]) :-
    take_obs_rand(Observations, Rand_Ob),
    Length_ is Length - 1,
    gen_trace_of_length(Length_, Observations, Output).

take_obs_rand([], []).
take_obs_rand([H_ | T], [H | O]) :-
    R is random(2),
    ((R = 1) -> H = H_; H = -H_),
    take_obs_rand(T, O).
