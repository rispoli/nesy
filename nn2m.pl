:- [rule_system2nn].
:- [utils].

default_on(1).
default_off(0, null).
default_off(-1, negative).

nn2m(F, Beta, Delta, Mfile) :-
    nn2m(F, Beta, Delta, [], Mfile).
nn2m(F, Beta, Delta, Trace, Mfile) :-
    rule_system2nn(F, Beta, Delta, (Initial_input, IO_layer, H_layer, IH, HO, PT_check, Theta_O, Theta_H, A_min, (F_Ob, L_Ob))),
    reset_gensym,
    tell(Mfile),
    format('% steepness parameter~nbeta = ~w;~n~na_min = ~w;~n~n', [Beta, A_min]),
    print_array(IO_layer, Initial_input, negative, 'initial_input = [', '%'),
    print_matrix(IO_layer, H_layer, IH, ih, 'IH = [', '% rows:'),
    format('\nfunction HO = get_HO(observation, obs_range);~n'),
        print_matrix(H_layer, IO_layer, HO, ho, '\tHO = [', '% rows:'),
    format('end~n~n'),
    print_theta(Theta_H, 'theta_H = [', '%'),
    print_theta(Theta_O, 'theta_O = [', '%'),
    print_array(IO_layer, PT_check, null, 'forbidden_state_mask = [', '%'),
    format('obs_range = [ ~w ~w ];~n~n', [F_Ob, L_Ob]),
    ((Trace = []) ->
        format('trace = [];~n');
        print_trace(Trace, IO_layer, 'trace = [')),
    format('trace(1, :) = [initial_input(:, 1:(obs_range(1) - 1)), zeros(1, obs_range(2) - obs_range(1) + 1)] .+ trace(1, :);~n~n'),
    format('[outputs, satisfying_run] = monitoring(trace, IH, @get_HO, theta_H, theta_O, obs_range, a_min, beta, forbidden_state_mask);~n'),
    told.

print_array([], _, _, A, C) :-
    format('~w~n~w ];~n~n', [C, A]).
print_array([H | T], I, M, A, C) :-
    format(atom(C_), '~w ~w', [C, H]),
    (memberchk(H, I) ->
        (default_on(On), format(atom(A_), '~w ~w', [A, On]));
        (default_off(Off, M), format(atom(A_), '~w ~w', [A, Off]))),
    print_array(T, I, M, A_, C_).

print_matrix([], C, _, Type, M, R) :-
    ((Type = ih) ->
        format('~w~n% columns:', [R]);
        format('\t~w~n\t% columns:', [R])),
    maplist(format(' ~w'), C),
    format('~n~w ];~n', [M]).
print_matrix([H | T], C, Arcs, Type, M, R) :-
    format(atom(R_), '~w ~w', [R, H]),
    print_arcs(C, H, Arcs, Type, M, M_),
    print_matrix(T, C, Arcs, Type, M_, R_).
print_arcs([], _, _, ih, M, M_) :-
    !, format(atom(M_), '~w;', [M]).
print_arcs([H | T], R, Arcs, ih, M, M_) :-
    !, (memberchk(a(R, H, W), Arcs) ->
        format(atom(M_T), '~w (~w)', [M, W]);
        (default_off(Off, null), format(atom(M_T), '~w ~w', [M, Off]))),
    print_arcs(T, R, Arcs, ih, M_T, M_).
print_arcs(Dest, _, [], ho, M, M_) :-
    !, maplist(off, Dest, Offs),
    foldl_(atom_concat, M, Offs, M__),
    format(atom(M_), '~w;', [M__]).
print_arcs(Dest, Src, [[[]] | T], ho, M, M_) :-
    !, print_arcs(Dest, Src, T, ho, M, M_).
print_arcs(Dest, Src, [[[a(Src, D, W) | T_Src]] | _], ho, M, M_) :-
    !, print_arcs(Dest, Src, [a(Src, D, W) | T_Src], ih, M, M_).
print_arcs(Dest, Src, [L | _], ho, M, M_) :-
    length(L, Len), Len > 1,
    L = [[a(Src, D, W) | T_Src] | T], !,
    maplist(print_arcs_m(Dest, Src, ih, ''), [[a(Src, D, W) | T_Src] | T], Alternatives),
    gensym(alternative_, Choice),
    foldl_(atom_concat, Choice, [' = [' | Alternatives], Alt_matrix),
    format(atom(M_), '\t% alternatives for: ~w~n\t~w ];~n~w choose(~w, observation, obs_range);', [Src, Alt_matrix, M, Choice]).
print_arcs(Dest, Src, [_ | T], ho, M, M_) :-
    print_arcs(Dest, Src, T, ho, M, M_).
off(_, O) :-
    default_off(Off, null),
    atom_concat(' ', Off, O).
print_arcs_m(Dest, Src, ih, M, L, M_) :-
    print_arcs(Dest, Src, L, ih, M, M_).

print_theta([], Ths, C) :-
    format('~w~n~w ];~n~n', [C, Ths]).
print_theta([(RN, Theta) | T], Ths, C) :-
    format(atom(Ths_), '~w (~w)', [Ths, Theta]),
    format(atom(C_), '~w r(~w)', [C, RN]),
    print_theta(T, Ths_, C_).

print_trace([], _, Tr) :-
    format('~w ];~n', [Tr]).
print_trace([H | T], IO_layer, Tr) :-
    print_trace_(IO_layer, H, Tr, Tr_),
    print_trace(T, IO_layer, Tr_).
print_trace_([], _, Tr, Tr_) :-
    format(atom(Tr_), '~w;', [Tr]).
print_trace_([-r(_) | T], Trace_E, Tr, Tr_) :-
    !, format(atom(Tr__), '~w 0', [Tr]),
    print_trace_(T, Trace_E, Tr__, Tr_).
print_trace_([r(_) | T], Trace_E, Tr, Tr_) :-
    !, format(atom(Tr__), '~w 0', [Tr]),
    print_trace_(T, Trace_E, Tr__, Tr_).
print_trace_([H | T], Trace_E, Tr, Tr_) :-
    (member(H, Trace_E) ->
        (default_on(On), format(atom(Tr__), '~w ~w', [Tr, On]));
        (default_off(Off, negative), format(atom(Tr__), '~w ~w', [Tr, Off]))),
    print_trace_(T, Trace_E, Tr__, Tr_).
