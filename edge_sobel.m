function [grayscale_edges, binary_edges] = edge_sobel(I)
    I_gray = rgb2gray(I);

    % Sobel operator
    SobelX = [-1 0 1; -2 0 2; -1 0 1];
    SobelY = SobelX';

    % Convolve image with Sobel filters
    Gx = conv2(double(I_gray), SobelX, 'same');
    Gy = conv2(double(I_gray), SobelY, 'same');

    % Compute magnitude of the gradient
    grayscale_edges = sqrt(Gx.^2 + Gy.^2);

    % Normalize values to [0, 1]
    grayscale_edges = grayscale_edges / max(grayscale_edges(:));

    % Convert to binary using a threshold
    threshold = 0.1; % You can adjust this threshold value
    binary_edges = grayscale_edges > threshold;
end