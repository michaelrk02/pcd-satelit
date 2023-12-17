function e = masked_entropi(I, M)
    M = double(M);
    M(abs(M) < 0.05) = NaN;

    e = entropy(rmmissing(reshape(M .* I, 1, [])));
end