tp(true, ([], [], [], [[]], [], [[]])) :- !.
tp(false, ([], [], [], [], [], [])) :- !.
tp(-Q, ([], [Q], [], [[]], [], [[-Q]])) :-
    atom(Q), !.
tp(Phi and Psi, (R, O, P, I, S, Q)) :-
    !, tp(Phi, (R_Phi, O_Phi, P_Phi, I_Phi, S_Phi, Q_Phi)),
    tp(Psi, (R_Psi, O_Psi, P_Psi, I_Psi, S_Psi, Q_Psi)),
    union(R_Phi, R_Psi, R),
    union(O_Phi, O_Psi, O),
    union(P_Phi, P_Psi, P),
    cartesian_prod(I_Phi, I_Psi, I),
    union(S_Phi, S_Psi, S),
    cartesian_prod(Q_Phi, Q_Psi, Q).
tp(Phi or Psi, (R, O, P, I, S, Q)) :-
    !, tp(Phi, (R_Phi, O_Phi, P_Phi, I_Phi, S_Phi, Q_Phi)),
    tp(Psi, (R_Psi, O_Psi, P_Psi, I_Psi, S_Psi, Q_Psi)),
    union(R_Phi, R_Psi, R),
    union(O_Phi, O_Psi, O),
    union(P_Phi, P_Psi, P),
    union(I_Phi, I_Psi, I),
    union(S_Phi, S_Psi, S),
    union(Q_Phi, Q_Psi, Q).
tp(s(Phi, Psi), (R, O, P, [I], S, [[r(s(Phi, Psi))]])) :-
    !, tp(Phi, (R_Phi, O_Phi, P_Phi, _, S_Phi, Q_Phi)),
    tp(Psi, (R_Psi, O_Psi, P_Psi, _, S_Psi, Q_Psi)),
    findall(r(qm(Phi, s(Phi, Psi), X)), member(X, Q_Phi), Rqm_Phi),
    findall(r(qm(Psi, s(Phi, Psi), Y)), member(Y, Q_Psi), Rqm_Psi),
    union(Rqm_Phi, Rqm_Psi, Rqm),
    union([r(s(Phi, Psi)), r(qm(g, s(Phi, Psi))) | R_Phi], R_Psi, R_), union(R_, Rqm, R),
    union(O_Phi, O_Psi, O),
    union(P_Phi, P_Psi, P_),
    findall(r(qm(Psi, s(Phi, Psi), Y), [Y], [[r(s(Phi, Psi))]]), member(Y, Q_Psi), Rqm_P_Psi),
    findall(r(qm(Phi, s(Phi, Psi), X), [X, r(s(Phi, Psi))], [[r(s(Phi, Psi))]]), member(X, Q_Phi), Rqm_P_Phi),
    union([r(qm(g, s(Phi, Psi)))], Rqm, B_P1),
    union(P_, [r(qm(g, s(Phi, Psi)), [], B_P1) | Rqm_P_Psi], P__), union(P__, Rqm_P_Phi, P),
    union(Rqm, [r(qm(g, s(Phi, Psi)))], I),
    union([-r(s(Phi, Psi)) | S_Phi], S_Psi, S).
tp(z(Phi, Psi), (R, O, P, [I], S, [[r(z(Phi, Psi))]])) :-
    !, tp(Phi, (R_Phi, O_Phi, P_Phi, _, S_Phi, Q_Phi)),
    tp(Psi, (R_Psi, O_Psi, P_Psi, _, S_Psi, Q_Psi)),
    findall(r(qm(Phi, z(Phi, Psi), X)), member(X, Q_Phi), Rqm_Phi),
    findall(r(qm(Psi, z(Phi, Psi), Y)), member(Y, Q_Psi), Rqm_Psi),
    union(Rqm_Phi, Rqm_Psi, Rqm),
    union([r(z(Phi, Psi)), r(qm(g, z(Phi, Psi))) | R_Phi], R_Psi, R_), union(R_, Rqm, R),
    union(O_Phi, O_Psi, O),
    union(P_Phi, P_Psi, P_),
    findall(r(qm(Psi, z(Phi, Psi), Y), [Y], [[r(z(Phi, Psi))]]), member(Y, Q_Psi), Rqm_P_Psi),
    findall(r(qm(Phi, z(Phi, Psi), X), [X, r(z(Phi, Psi))], [[r(z(Phi, Psi))]]), member(X, Q_Phi), Rqm_P_Phi),
    union([r(qm(g, z(Phi, Psi)))], Rqm, B_P1),
    union(P_, [r(qm(g, z(Phi, Psi)), [], B_P1) | Rqm_P_Psi], P__), union(P__, Rqm_P_Phi, P),
    union(Rqm, [r(qm(g, z(Phi, Psi)))], I),
    union([r(z(Phi, Psi)) | S_Phi], S_Psi, S).
tp(P, ([], [P], [], [[]], [], [[P]])) :-
    atom(P).
