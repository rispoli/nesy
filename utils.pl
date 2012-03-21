foldl_(_, O, [], O) :- !.
foldl_(F, I, [H | T], O) :-
    call(F, I, H, NI),
    foldl_(F, NI, T, O).

foldl1(F, [H | T], O) :-
    foldl(F, H, T, O).

foldl(_, O, [], O) :- !.
foldl(F, I, [H | T], O) :-
    NI =.. [F, I, H],
    foldl(F, NI, T, O).
