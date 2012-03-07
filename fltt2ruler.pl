tf(true, ([r(g)], [], [r(g, [], [[r(g)]])], [[r(g)]], [])) :- !.
tf(false, ([], [], [], [], [])) :- !.
tf(-Q, ([r(g)], [Q], [r(g, [], [[r(g)]])], [[-Q, r(g)]], [])) :-
    atom(Q), !.
tf(Phi and Psi, (R, O, P, I, F)) :-
    !, tf(Phi, (R_Phi, O_Phi, P_Phi, I_Phi, F_Phi)),
    tf(Psi, (R_Psi, O_Psi, P_Psi, I_Psi, F_Psi)),
    union(R_Phi, R_Psi, R),
    union(O_Phi, O_Psi, O),
    union(P_Phi, P_Psi, P),
    cartesian_prod(I_Phi, I_Psi, I),
    union(F_Phi, F_Psi, F).
tf(Phi or Psi, (R, O, P, I, F)) :-
    !, tf(Phi, (R_Phi, O_Phi, P_Phi, I_Phi, F_Phi)),
    tf(Psi, (R_Psi, O_Psi, P_Psi, I_Psi, F_Psi)),
    union(R_Phi, R_Psi, R),
    union(O_Phi, O_Psi, O),
    union(P_Phi, P_Psi, P),
    union(I_Phi, I_Psi, I),
    union(F_Phi, F_Psi, F).
tf(u(Phi, Psi), (R, O, P, [[r(u(Phi, Psi))]], F)) :-
    !, tf(Phi, (R_Phi, O_Phi, P_Phi, I_Phi, F_Phi)),
    tf(Psi, (R_Psi, O_Psi, P_Psi, I_Psi, F_Psi)),
    union([r(u(Phi, Psi)) | R_Phi], R_Psi, R),
    union(O_Phi, O_Psi, O),
    cartesian_prod(I_Phi, [[r(u(Phi, Psi))]], I_PhixR),
    union(I_Psi, I_PhixR, B_R),
    union([r(u(Phi, Psi), [], B_R) | P_Phi], P_Psi, P),
    union([r(u(Phi, Psi)) | F_Phi], F_Psi, F).
tf(w(Phi, Psi), (R, O, P, [[r(w(Phi, Psi))]], F)) :-
    !, tf(Phi, (R_Phi, O_Phi, P_Phi, I_Phi, F_Phi)),
    tf(Psi, (R_Psi, O_Psi, P_Psi, I_Psi, F_Psi)),
    union([r(w(Phi, Psi)) | R_Phi], R_Psi, R),
    union(O_Phi, O_Psi, O),
    cartesian_prod(I_Phi, [[r(w(Phi, Psi))]], I_PhixR),
    union(I_Psi, I_PhixR, B_R),
    union([r(w(Phi, Psi), [], B_R) | P_Phi], P_Psi, P),
    union(F_Phi, F_Psi, F).
tf(P, ([r(g)], [P], [r(g, [], [[r(g)]])], [[P, r(g)]], [])) :-
    atom(P).

% Tests:
?- tf(u(a, b), ([r(u(a, b)), r(g)], [a, b], [r(u(a, b), [], [[b, r(g)], [a, r(g), r(u(a, b))]]), r(g, [], [[r(g)]])], [[r(u(a, b))]], [r(u(a, b))])).
?- tf(a and w(c, d),([r(w(c, d)), r(g)], [a, c, d], [r(w(c, d), [], [[d, r(g)], [c, r(g), r(w(c, d))]]), r(g, [], [[r(g)]])], [[a, r(g), r(w(c, d))]], [])).
?- tf(u(u(a, b), a and w(c, d)), ([r(u(u(a, b), a and w(c, d))), r(u(a, b)), r(w(c, d)), r(g)], [b, a, c, d], [r(u(u(a, b), a and w(c, d)), [], [[a, r(g), r(w(c, d))], [r(u(a, b)), r(u(u(a, b), a and w(c, d)))]]), r(u(a, b), [], [[b, r(g)], [a, r(g), r(u(a, b))]]), r(w(c, d), [], [[d, r(g)], [c, r(g), r(w(c, d))]]), r(g, [], [[r(g)]])], [[r(u(u(a, b), a and w(c, d)))]], [r(u(u(a, b), a and w(c, d))), r(u(a, b))])).
