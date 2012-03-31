:- [gtsi2ruler].
:- [utils].

rule_system2nn(Phi => Psi, Beta, Delta, (Initial_input, IO_layer, R, IH, HO, F, Theta_O, Theta_H, A_min, Obs_range)) :-
    t(Phi, Psi, (R_, O, P_, I_, F)),
    strip_generator(R_, P_, I_, R, P_ND, I),
    determinization(P_ND, O, P),
    mus_ks(P, Mus, P_Aug, Max_P),
    A_min is ((Max_P - 1) / (Max_P + 1)) + Delta,
    W is (2 / Beta) * ((log(1 + A_min) - log(1 - A_min)) / (Max_P * (A_min - 1) + A_min + 1)),
    io_layer(R, O, IO_layer, Obs_range),
    initial_input(I, R, Initial_input),
    ih_ho(P_Aug, A_min, W, IH_, HO, Theta_H), flatten(IH_, IH),
    theta_O(IO_layer, Mus, A_min, W, Theta_O).

strip_generator(R_, P_, I_, R, P, I) :-
    exclude(gen_name, R_, R),
    strip_generator(P_, P),
    maplist(exclude(gen_name), I_, I).
strip_generator([], []).
strip_generator([r(g, _, _) | T], T_) :-
    !, strip_generator(T, T_).
strip_generator([r(N, C, B_) | T], [r(N, C, B) | T_]) :-
    maplist(exclude(gen_name), B_, B),
    strip_generator(T, T_).
gen_name(r(g)).

determinization(P_ND, O_P, P) :-
    maplist(neg, O_P, O_N), append(O_P, O_N, O_PN),
    determinization_(P_ND, O_PN, P).
determinization_([], _, []).
determinization_([r(N, C, B_) | T], O, [r(N, C, B) | T_]) :-
    flatten(B_, B_F), list_to_set(B_F, B_S), intersection(B_S, O, B_O),
    maplist(determinize(B_O), B_, B),
    determinization_(T, O, T_).
determinize(B_O, B_, B) :-
    subtract(B_O, B_, B_NO),
    maplist(neg, B_NO, B_N),
    append(B_, B_N, B).

neg(-X, X) :- !.
neg(X, -X).

mus_ks(P, Mus, P_Aug, Max_P) :-
    mus_ks(P, [], Mus, P_Aug, Max_P).
mus_ks([], Mus, Mus, [], 0).
mus_ks([r(N, C, B) | T], Mus, Mus_, [r(N, C, B, k(K)) | T_], Max_P) :-
    length(C, K),
    flatten(B, B_), list_to_set(B_, Bs),
    foldl_(inc_mus, Mus, Bs, Mus__),
    mus_ks(T, Mus__, Mus_, T_, Max_P_),
    ((Bs = []) ->
        Mu = 0;
        (extract_mus(Bs, Mus_, Mus___), max_list(Mus___, Mu))),
    max_list([Max_P_, K, Mu], Max_P).
inc_mus(Mus, X, Mus_) :-
    memberchk((X, Mu), Mus) ->
        (Mu_ is Mu + 1, selectchk((X, Mu), Mus, (X, Mu_), Mus_));
        Mus_ = [(X, 1) | Mus].
extract_mus([], _, []).
extract_mus([H | T], Mus, [Mu | T_]) :-
    memberchk((H, Mu), Mus),
    extract_mus(T, Mus, T_).

io_layer(R, O, IO_layer, (F_Ob, L_Ob)) :-
    append(R, O, RO),
    length(R, F_Ob_), length(O, L_Ob_),
    F_Ob is F_Ob_ * 2 + 1, L_Ob is L_Ob_ * 2 + F_Ob - 1,
    maplist(pn, RO, RO_pn),
    flatten(RO_pn, IO_layer).
pn(X, [X, -X]).

initial_input([I], R, Initial_input) :-
    subtract(R, I, R_to_neg),
    maplist(neg, R_to_neg, R_neg),
    append(I, R_neg, Initial_input).

ih_ho([], _, _, [], [], []).
ih_ho([r(RN, C, B, k(K)) | T], A_min, W, [C_arcs | IH_T], [B_arcs | HO_T], [(RN, Theta_H) | Theta_H_]) :-
    c_arcs(C, RN, W, C_arcs),
    b_arcs(B, RN, W, B_arcs),
    Theta_H is (((1 + A_min) * (K - 1)) / 2) * W,
    ih_ho(T, A_min, W, IH_T, HO_T, Theta_H_).
c_arcs([], RN, W, [a(r(RN), r(RN), W)]).
c_arcs([H | T], RN, W, [a(H, r(RN), W) | H_T]) :-
    c_arcs(T, RN, W, H_T).
b_arcs([], _, _, []).
b_arcs([H | T], RN, W, [BH_arcs | B_T]) :-
    b_arcs_(H, RN, W, BH_arcs),
    b_arcs(T, RN, W, B_T).
b_arcs_([], _, _, []).
b_arcs_([H | T], RN, W, [a(r(RN), H, W) | B_T]) :-
    b_arcs_(T, RN, W, B_T).

theta_O([], _, _, _, []).
theta_O([H | T], Mus, A_min, W, [(H, Theta_O) | T_]) :-
    (member((H, Mu), Mus) ->
        true;
        Mu = 0),
    Theta_O is (((1 + A_min) * (1 - Mu)) / 2) * W,
    theta_O(T, Mus, A_min, W, T_).
