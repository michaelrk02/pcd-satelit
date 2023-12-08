function feature_extraction()

    fprintf('Loading segmented image ...\n');
    Segmented_image = imread('data/segments-repaired.jpg');
    
    % Convert the segmented image to grayscale
    I_gray = rgb2gray(Segmented_image);

    % Feature extraction
    fprintf('Extracting features ...\n');
    mean_intensity = mean(I_gray(:));
    std_dev_intensity = std(double(I_gray(:)));
    entropy_intensity = entropy(I_gray);

    % Display the computed features
    fprintf('Mean Intensity: %.4f\n', mean_intensity);
    fprintf('Standard Deviation of Intensity: %.4f\n', std_dev_intensity);
    fprintf('Entropy of Intensity: %.4f\n', entropy_intensity);

    fprintf('Feature extraction complete.\n');
end