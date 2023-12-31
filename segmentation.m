function segmentation()
    segments = 3;
    H_gauss = kernelize(@G, (-5:5));

    fprintf('Loading image ...\n');
    I = imread('data/input.jpg');
    I_raw = I;

    D = size(I);
    r = D(1);
    c = D(2);

    fprintf('Performing HSV segmentation ...\n');
    Seg = hsv_segments(I, @thresh, segments);
    Seg_raw = Seg;

    repairs = 3;
    combined_edges = zeros(r, c); % Initialize combined_edges
    
    for i = 1:repairs
        Seg_old = Seg;
        Seg = zeros(r, c);

        fprintf('Repairing segmentation (%d of %d) ...\n', i, repairs);

        for k = 1:segments
            M = decompose_segment(Seg_old, segments, k);
            if i == 1
                imwrite(M, sprintf('data/segments-decompose-%d-raw.png', k));
            end

            fprintf('- Removing noise on segment %d ...\n', k);
            M = imfilter(M, H_gauss);
            imwrite(M, sprintf('data/segments-decompose-%d-gauss.png', k));

            M = double(im2bw(M, 0.5));

            Seg = compose_segment(Seg, segments, k, M);

            imwrite(M, sprintf('data/segments-decompose-%d-repaired.png', k));
            
            % Add edge detection step
            fprintf('Performing edge detection ...\n');
            [grayscale_edges, binary_edges] = edge_sobel(M);

            imwrite(grayscale_edges, sprintf('data/edges-detection-%d.png', k));
            imwrite(binary_edges, sprintf('data/binary_edges-detection-%d.png', k));
            
            % Combine binary edges using element-wise addition
            combined_edges = combined_edges + binary_edges;

            fprintf('Segmentation and edge detection complete.\n');
        end
    end

    imwrite(colorize_segments(Seg_raw), 'data/segments-raw.png');
    imwrite(colorize_segments(Seg), 'data/segments-repaired.png');
    
    % Threshold combined_edges to create a binary map
    threshold_combined_edges = combined_edges > 0;
    imwrite(threshold_combined_edges, 'data/combined_edges-detection.png');
    
    imwrite(imfuse(I_raw, colorize_segments(Seg), 'blend'), 'data/segments-image.png');
    
    imwrite(imfuse(I_raw, threshold_combined_edges, 'blend'), 'data/detection-image.png');

    fprintf('Segmentation and edge detection complete.\n');

    % Display and save segmented images
    feature_extraction('Vegetations', Seg, 1, H_gauss, I);
    feature_extraction('Soil', Seg, 2, H_gauss, I);
    feature_extraction('Buildings', Seg, 3, H_gauss, I);
end
 
function d = hsv_dist(A, B, W)
    d = norm(W .* (A - B));
end

function f = thresh(n, h, s, v)
    % Vegetations
    VE1C = [0.35 0.4 0.3];
    VE1W = [2.25 0.25 0.25];

    % Soil
    SL1C = [0.15 0.2 0.3];
    SL1W = [3.0 2.5 2.5];

    % Buildings
    BD1C = [0.2 0.1 0.3];
    BD1W = [0.05 0.5 0.5];

    HSV = [h s v];
    t = 0.25;

    if hsv_dist(HSV, VE1C, VE1W) < t
        f = segment(n, 1);
    elseif hsv_dist(HSV, SL1C, SL1W) < t 
        f = segment(n, 2);
    elseif hsv_dist(HSV, BD1C, BD1W) < t
        f = segment(n, 3);
    else
        f = segment(n, 0);
    end
end

function t_fix = thresh_repair(t, n)
    m = n + 1;
    for i = 1:m
        if t >= segment(m, m - i)
            t_fix = segment(m - 1, m - i);
            break;
        end
    end
end
 

function I_out = compose_segment(I, n, k, M)
    I_out = I;
    t = segment(n, k);

    D = size(I);
    r = D(1);
    c = D(2);
    for i = 1:r
        for j = 1:c
            if I(i, j) == 0
                if M(i, j) > 0.5
                    I_out(i, j) = t;
                endif
            end
        end
    end
end

function I_out = hsv_segments(I, t, n)
    I = rgb2hsv(I);

    D = size(I);
    r = D(1);
    c = D(2);
    I_out = uint32(zeros(r, c));

    for i = 1:r
        for j = 1:c
            h = I(i, j, 1);
            s = I(i, j, 2);
            v = I(i, j, 3);
            I_out(i, j) = t(n, h, s, v);
        end
    end
end
 
function k = kernelize(f, R)
    s = size(R,2);
    X = repmat(R, s, 1);
    Y = repmat(R', 1, s);
    k = f(X, Y);
    k = k / sum(reshape(k, 1, []));
end

function z = G(x, y)
    s = 5.0;
    z = 1/(2*pi*s^2)*exp(-((x.^2+y.^2)/(2*s^2)));
end   

 

