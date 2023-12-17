function I_out = colorize_segments(I)
    D = size(I);
    r = D(1);
    c = D(2);

    H = zeros(r, c);
    S = 1.0 * ones(r, c);
    V = 0.75 * ones(r, c);
    for i = 1:r
        for j = 1:c
            if I(i, j) >= 0.05
                H(i,j) = 0.75 * I(i,j);
            else
                V(i,j) = 0.0;
            end
        end
    end

    I_out = hsv2rgb(cat(3, H, S, V));
end