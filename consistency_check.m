% y = true = 1 -> inconsistent result
% y = false = 0 -> consistent result
function y = consistency_check(M, a_min)
    y = cons_or(pairwise_and(M > a_min));
end

function y = pairwise_and(M)
    [cols, rows] = size(M);
    y = [];

    for i = 1:cols
        and_row = [];
        for j = 1:2:rows
            and_row = [and_row and(M(i, j), M(i, j + 1))];
        end
        y = [y; and_row];
    end
end

function y = cons_or(M)
    [cols, rows] = size(M);
    y = false;

    for i = 1:cols
        or_row = false;
        for j = 1:rows
            or_row = or(or_row, M(i, j));
        end
        y = or(y, or_row);
    end
end
