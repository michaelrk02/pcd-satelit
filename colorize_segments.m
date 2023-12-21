function I_out = colorize_segments(I)
    D = size(I);
    r = D(1);
    c = D(2);

    H = zeros(r, c);
    S = ones(r, c);
    V = ones(r, c);
    for i = 1:r
        for j = 1:c
            if I(i, j) > 0
                %H(i,j) = 0.75 * I(i,j);
                if I(i, j) == 1
                    H(i,j) = 0.33;
                elseif I(i, j) == 2
                    H(i,j) = 0.00;
                elseif I(i, j) == 3
                    H(i,j) = 0.67;
                end
            else
                V(i,j) = 0.0;
            end
        end
    end

    I_out = hsv2rgb(cat(3, H, S, V));
end
