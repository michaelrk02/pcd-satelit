
function feature_extraction(segment_name, Seg, k, H_gauss,I) 
    HSV = rgb2hsv(I);
    H = HSV(:,:,1);
    S = HSV(:,:,2);
    V = HSV(:,:,3);
    
    fprintf('Displaying and saving segmentation for %s ...\n', segment_name);
    
    M = decompose_segment(Seg, 3, k);
    
    fprintf('- Removing noise on segment %s ...\n', segment_name);
    M = imfilter(M, H_gauss);
    
    fprintf('- Converting to binary image ...\n');
    M_binary = double(im2bw(M, 0.5));
    
    % Extract features
    mean_H_val = masked_mean(H,M); 
    mean_S_val = masked_mean(S,M); 
    mean_V_val = masked_mean(V,M); 
    % mean_val = mean(M(:));
    std_H_val = masked_std(H, M)
    std_S_val = masked_std(S, M)
    std_V_val = masked_std(V, M)
    
    entropy_H_val = masked_entropi(H, M)
    entropy_S_val = masked_entropi(S, M)
    entropy_V_val = masked_entropi(V, M)
    
    % Display the segmented image and features
    figure;
    
    % Display the segmented image
    subplot(2, 2, 1), imshow(hsv2rgb((cat(3, H.*M, S.*M, V.*M)))), title(sprintf('%s Segment', segment_name));
    
    % Display the binary image
    subplot(2, 2, 2), imshow(M_binary), title(sprintf('%s Binary', segment_name));
    
    % Display the mean value
    subplot(5, 1, 3);
    text(0.5, 0.5, sprintf('Mean H: %.4f || Mean S: %.4f || Mean V: %.4f', mean_H_val, mean_S_val, mean_V_val), 'Color', 'b', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    axis off;
    
    % Display the standard deviation value
    subplot(5, 1, 4);
    text(0.5, 0.5, sprintf('Std H: %.4f || Std S: %.4f || Std V: %.4f ', std_H_val, std_S_val, std_V_val), 'Color', 'b', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    axis off;
    
    % Display the entropy value
    subplot(5, 1, 5);
    text(0.5, 0.5, sprintf('Entropy H: %.4f || Entropy S: %.4f || Entropy V: %.4f ', entropy_H_val, entropy_S_val, entropy_V_val), 'Color', 'b', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    axis off;
    
    % Save the segmented image
    imwrite(hsv2rgb((cat(3, H.*M, S.*M, V.*M))), sprintf('data/%s-segment.jpg', lower(segment_name)));
    imwrite(M_binary, sprintf('data/%s-binary.jpg', lower(segment_name)));
end
 