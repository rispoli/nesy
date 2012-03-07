:- op(400, fy, -),
   op(500, yfx, and),
   op(600, yfx, or),
   op(700, xfy, =>).

cartesian_prod(A, B, AxB) :-
    findall(E, (member(EA, A), member(EB, B), append(EA, EB, E)), AxB).

:- [fltt2ruler].
:- [pptt2ruler].

t(Phi, Psi, (R, O, P, I, F_Future)) :-
    tp(Phi, (R_Past, O_Past, P_Past, I_Past, S_Past, Q_Past)),
    tf(Psi, (R_Future, O_Future, P_Future, I_Future, F_Future)),
    union([r((g, Phi => Psi)) | R_Past], R_Future, R_),
    findall(r(X => Psi), member(X, Q_Past), RXPsi), union(R_, RXPsi, R),
    union(O_Past, O_Future, O),
    union(P_Past, P_Future, P_),
    findall(r(X => Psi, [X], I_Future), member(X, Q_Past), RXPsiI),
    union(P_, [r((g, Phi => Psi), [], [[r((g, Phi => Psi))] | RXPsi])], P__), union(P__, RXPsiI, P),
    union([r((g, Phi => Psi)) | RXPsi], S_Past, RXPsiUS),
    subtract(I_Past, R_Past, IsR),
    cartesian_prod([RXPsiUS], IsR, I).
