:- [gtsi2ruler].

monitor(Past => Future, Trace) :-
    monitor(Past => Future, Trace, _).

monitor(Past => Future, Trace, Steps) :-
    t(Past, Future, (_, _, P, I, F)),
    monitor_(Trace, I, P, F, Steps).

monitor_([], I, _, F, []) :-
    maplist(intersection(F), I, Is),
    memberchk([], Is).
monitor_([H | T], I, P, F, [(H, I, Res_C) | S]) :-
    resultant_states(H, I, Res),
    check_consistency(Res, Res_C),
    ((Res_C = []) ->
        (!, fail);
        (next_activation_states(Res_C, P, I_),
        monitor_(T, I_, P, F, S))).

resultant_states(Obs, Rule_activations, Resultant_states) :-
    maplist(union(Obs), Rule_activations, Resultant_states).

check_consistency([], []).
check_consistency([H | T], T_) :-
    member(-X, H),
    member(X, H), !,
    check_consistency(T, T_).
check_consistency([H | T], [H | T_]) :-
    check_consistency(T, T_).

next_activation_states([], _, [[]]).
next_activation_states([H | T], P, T_) :-
    next_activation_state(P, H, H_),
    next_activation_states(T, P, T__),
    cartesian_prod(H_, T__, T_).

next_activation_state([], _, [[]]).
next_activation_state([r(N, Conditions, Body) | T], Resultant_state, T_) :-
    member(r(N), Resultant_state),
    subset(Conditions, Resultant_state), !,
    next_activation_state(T, Resultant_state, T__),
    cartesian_prod(Body, T__, T_).
next_activation_state([_ | T], Resultant_state, T_) :-
    next_activation_state(T, Resultant_state, T_).
