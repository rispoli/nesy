:- op(400, fy, -),
   op(500, yfx, and),
   op(600, yfx, or),
   op(700, xfy, =>).

cartesian_prod(A, B, AxB) :-
    findall(E, (member(EA, A), member(EB, B), union(EA, EB, E)), AxB).

foldl1(F, [H | T], O) :-
    foldl(F, H, T, O).

foldl(_, O, [], O) :- !.
foldl(F, I, [H | T], O) :-
    NI =.. [F, I, H],
    foldl(F, NI, T, O).

:- [fltt2ruler].
:- [pptt2ruler].

t(Phi, Psi, (R, O, P, I, F_Future)) :-
    tp(Phi, (R_Past, O_Past, P_Past, I_Past, S_Past, Q_Past)),
    tf(Psi, (R_Future, O_Future, P_Future, I_Future, F_Future)),
    union([r((g, Phi => Psi)) | R_Past], R_Future, R_),
    findall(r(X => Psi), (member(X_, Q_Past), foldl1(and, X_, X)), RXPsi), union(R_, RXPsi, R),
    union(O_Past, O_Future, O),
    union(P_Past, P_Future, P_),
    findall(r(X => Psi, X_, I_Future), (member(X_, Q_Past), foldl1(and, X_, X)), RXPsiI),
    union(P_, [r((g, Phi => Psi), [], [[r((g, Phi => Psi)) | RXPsi]])], P__), union(P__, RXPsiI, P),
    union([r((g, Phi => Psi)) | RXPsi], S_Past, RXPsiUS),
    subtract(I_Past, R_Past, IsR),
    cartesian_prod([RXPsiUS], IsR, I).

% Test:
?- t(c and s(b, a), (p or u(true, p)) and (q or u(true, q)), ([r((g,c and s(b,a)=> (p or u(true,p))and (q or u(true,q)))),r(s(b,a)),r(qm(g,s(b,a))),r(qm(b,s(b,a),b)),r(qm(a,s(b,a),a)),r(u(true,p)),r(u(true,q)),r(g),r(c and r(s(b,a))=> (p or u(true,p))and (q or u(true,q)))],[c,b,a,p,q],[r(s(b,a),[],[[]]),r(qm(g,s(b,a)),[],[[r(qm(g,s(b,a))),r(qm(b,s(b,a),b)),r(qm(a,s(b,a),a))]]),r(qm(a,s(b,a),a),[a],[[r(s(b,a))]]),r(qm(b,s(b,a),b),[b,r(s(b,a))],[[r(s(b,a))]]),r(u(true,p),[],[[p,r(g)],[r(g),r(u(true,p))]]),r(u(true,q),[],[[q,r(g)],[r(g),r(u(true,q))]]),r(g,[],[[r(g)]]),r((g,c and s(b,a)=> (p or u(true,p))and (q or u(true,q))),[],[[r((g,c and s(b,a)=> (p or u(true,p))and (q or u(true,q)))),r(c and r(s(b,a))=> (p or u(true,p))and (q or u(true,q)))]]),r(c and r(s(b,a))=> (p or u(true,p))and (q or u(true,q)),[c,r(s(b,a))],[[p,q,r(g)],[p,r(g),r(u(true,q))],[r(u(true,p)),q,r(g)],[r(u(true,p)),r(u(true,q))]])],[[r((g,c and s(b,a)=> (p or u(true,p))and (q or u(true,q)))),r(c and r(s(b,a))=> (p or u(true,p))and (q or u(true,q))),-r(s(b,a)),r(qm(b,s(b,a),b)),r(qm(a,s(b,a),a)),r(qm(g,s(b,a)))]],[r(u(true,p)),r(u(true,q))])).
