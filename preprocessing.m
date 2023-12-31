function preprocessing()
    I = imread('satellite.jpg');
    D = size(I);
    r = D(1);
    c = D(2);

    HSV = rgb2hsv(I);

    H = HSV(:,:,1);
    S = HSV(:,:,2);
    V = HSV(:,:,3);

    V0_mean = mean(reshape(V, 1, []))
    V0_std = std(reshape(V, 1, []))

    Vf_mean = 0.3;
    Vf_std = 0.1;

    V = repair_transform(V, ones(r, c), V0_mean, V0_std, Vf_mean, Vf_std);

    imwrite(hsv2rgb(cat(3, H, S, V)), 'data/preprocessing-adjusted.jpg');

    mask_cmp_distinct = @(t, m, s) abs(t - m) > s;
    mask_cmp_average = @(t, m, s) abs(t - m) <= s;

    fprintf('Masking image based on the distinctive saturation range ...\n');
    M_distinct = mask(S, mask_cmp_distinct);
    M_average = mask(S, mask_cmp_average);

    imwrite(M_distinct, 'data/preprocessing-mask-distinct.png');
    imwrite(M_average, 'data/preprocessing-mask-average.png');

    fprintf('Repairing channels ...\n');

    fprintf('Repairing hue channel ...\n');
    H = repair(H, M_distinct, M_average);

    fprintf('Repairing saturation channel ...\n');
    S = repair(S, M_distinct, M_average);

    fprintf('Repairing value channel ...\n');
    V = repair(V, M_distinct, M_average);

    fprintf('Reconstructing image ...\n');
    I = hsv2rgb(cat(3, H, S, V));

    imwrite(I, 'data/input.jpg');

    fprintf('Preprocessing completed\n');
end

function I_out = mask(I, cmp)
    D = size(I);
    r = D(1);
    c = D(2);
    I_out = zeros(r, c);

    m = mean(reshape(I, 1, []))
    s = std(reshape(I, 1, []))

    for i = 1:r
        for j = 1:c
            if cmp(I(i,j), m, s)
                I_out(i,j) = 1;
            end
        end
    end

    %H = kernelize(@G, (-5:5));
    %I_out = im2bw(imfilter(double(I_out), H), 0.5);
end

function I_out = repair(I, M, T)
    m_mean = masked_mean(I, M)
    m_std = masked_std(I, M)

    t_mean = masked_mean(I, T)
    t_std = masked_std(I, T)

    I_out = repair_transform(I, M, m_mean, m_std, t_mean, t_std);
end

function I_out = repair_transform(I, M, s_mean, s_std, t_mean, t_std)
    D = size(I);
    r = D(1);
    c = D(2);
    I_out = I;

    for i = 1:r
        for j = 1:c
            if M(i,j) == 1
                I_out(i,j) = (I(i,j) - s_mean) / s_std;
                I_out(i,j) = I_out(i,j) * t_std + t_mean;
            end
        end
    end
end 

function k = kernelize(f, R)
    s = size(R, 2);
    X = repmat(R, s, 1);
    Y = repmat(R', 1, s);
    k = f(X, Y);
    k = k / sum(reshape(k, 1, []));
end

function z = G(x, y)
    s = 5.0;
    z = 1/(2*pi*s^2)*e.^-((x.^2+y.^2)/(2*s^2));
end
