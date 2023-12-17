function s = masked_std(I, M)
    M = double(M);
    M(abs(M) < 0.05) = NaN;

    s = std(rmmissing(reshape(M .* I, 1, [])));
end