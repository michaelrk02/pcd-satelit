function I_out = decompose_segment(I, n, k)
    D = size(I);
    r = D(1);
    c = D(2);
    I_out = zeros(r, c);
    t = segment(n, k);

    for i = 1:r
        for j = 1:c
            if abs(I(i, j) - t) <= 0.05
                I_out(i, j) = 1.0;
            end
        end
    end
end