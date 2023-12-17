function m = masked_mean(I, M)
    M = double(M);
    M(abs(M) < 0.05) = NaN;

    m = mean(rmmissing(reshape(M .* I, 1, [])));
end