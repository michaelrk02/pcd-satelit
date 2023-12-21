% matlab

function classification()
    S_predicted = rgb2hsv(imread('data/segments-repaired.png'));
    S_actual = rgb2hsv(imread('satellite-label.png'));

    fprintf('Segmentation result:\n');
    % score_segmentation(S_predicted, S_actual);
    fprintf('\n');

    fprintf('Edge detection result:\n');
    score_edges(S_predicted, S_actual);
    fprintf('\n');

    fprintf('Feature extraction result:\n');
    fprintf('\n');
end

function score_segmentation(S_predicted, S_actual)
    D = size(S_predicted);
    r = D(1);
    c = D(2);
    n_pixels = r * c;

    N_predicted = segment_counts(S_predicted)
    N_actual = segment_counts(S_actual)

    R_predicted = double(N_predicted) / n_pixels
    R_actual = double(N_actual) / n_pixels

    E = abs(R_predicted - R_actual)
    E_rms = sqrt(sum(E .^ 2.0) / 3)

    n_correct = 0;
    n_incorrect = 0;

    CM_vegetation = confusion_matrix();
    CM_soil = confusion_matrix();
    CM_building = confusion_matrix();

    for i = 1:r
        for j = 1:c
            L_predicted = [S_predicted(i,j,1) S_predicted(i,j,2) S_predicted(i,j,3)];
            L_actual = [S_actual(i,j,1) S_actual(i,j,2) S_actual(i,j,3)];

            k_predicted = label_to_segment(L_predicted);
            k_actual = label_to_segment(L_actual);

            if k_predicted == k_actual
                n_correct++;
            else
                n_incorrect++;
            end

            CM_vegetation = confusion_matrix_update(CM_vegetation, 1, k_predicted, k_actual);
            CM_soil = confusion_matrix_update(CM_soil, 2, k_predicted, k_actual);
            CM_building = confusion_matrix_update(CM_building, 3, k_predicted, k_actual);
        end
    end

    n_correct
    n_incorrect

    overall_accuracy = double(n_correct) / n_pixels

    report('vegetation', CM_vegetation);
    report('soil', CM_soil);
    report('building', CM_building);
end

function score_edges(S_predicted, S_actual)
    D = size(S_predicted);
    r = D(1);
    c = D(2);
    n_pixels = r * c;

    Seg_actual = int32(zeros(r, c));
    for i = 1:r
        for j = 1:c
            Seg_actual(i,j) = label_to_segment([S_actual(i,j,1) S_actual(i,j,2) S_actual(i,j,3)]);
        end
    end

    E_actual = zeros(r, c);
    for k = 1:3
        M = decompose_segment(Seg_actual, 3, k);

        [E_grayscale, E_binary] = edge_sobel(M);

        E_actual = E_actual + E_binary;
    end

    E_actual = E_actual > 0.05;
    imwrite(E_actual, 'data/edges-actual.png');

    E_predicted = imread('data/combined_edges-detection.png');
    imwrite(E_predicted, 'data/edges-predicted.png');

    n_tp = 0;
    n_tn = 0;
    n_fp = 0;
    n_fn = 0;

    for i = 1:r
        for j = 1:c
            c_predicted = E_predicted(i,j);
            c_actual = E_actual(i,j);

            if c_predicted && c_actual
                n_tp++;
            elseif c_predicted && ~c_actual
                n_fp++;
            elseif ~c_predicted && c_actual
                n_fn++;
            elseif ~c_predicted && ~c_actual
                n_tn++;
            end
        end
    end

    s_accuracy = double(n_tp + n_tn) / double(n_tp + n_tn + n_fp + n_fn);
    s_precision = double(n_tp) / double(n_tp + n_fp);
    s_recall = double(n_tp) / double(n_tp + n_fn);
    s_f1_score = 2.0 * s_precision * s_recall / (s_precision + s_recall);

    fprintf('Report:\n');
    fprintf('- True Positive: %d\n', n_tp);
    fprintf('- True Negative: %d\n', n_tn);
    fprintf('- False Positive: %d\n', n_fp);
    fprintf('- False Negative: %d\n', n_fn);
    fprintf('- Accuracy: %f\n', s_accuracy);
    fprintf('- Precision: %f\n', s_precision);
    fprintf('- Recall: %f\n', s_recall);
    fprintf('- F1-score: %f\n', s_f1_score);
end

function N = segment_counts(S)
    D = size(S);
    r = D(1);
    c = D(2);

    N = int32(zeros(1, 3));

    for i = 1:r
        for j = 1:c
            h = S(i,j,1);
            s = S(i,j,2);
            v = S(i,j,3);
            k = label_to_segment([h s v]);
            if k > 0
                N(k)++;
            end
        end
    end
end

function CM = confusion_matrix(S_predicted, S_actual)
    % TP | FP
    % FN | TN
    CM = int32(zeros(2, 2));
end

function CM_out = confusion_matrix_update(CM, k, k_predicted, k_actual)
    if (k_predicted == k) && (k_actual == k) % true positive
        CM(1,1)++;
    elseif (k_predicted == k) && (k_actual ~= k) % false positive
        CM(1,2)++;
    elseif (k_predicted ~= k) && (k_actual == k) % false negative
        CM(2,1)++;
    elseif (k_predicted ~= k) && (k_actual ~= k) % true negative
        CM(2,2)++;
    end
    CM_out = CM;
end

function a = accuracy(CM)
    a = double(CM(1,1) + CM(2,2)) / double(CM(1,1) + CM(1,2) + CM(2,1) + CM(2,2));
end

function p = precision(CM)
    p = double(CM(1,1)) / double(CM(1,1) + CM(1,2));
end

function r = recall(CM)
    r = double(CM(1,1)) / double(CM(1,1) + CM(2,1));
end

function f = f1_score(CM)
    p = precision(CM);
    r = recall(CM);
    f = 2.0 * p * r / (p + r);
end

function report(name, CM)
    fprintf('Report: %s\n', name);
    fprintf('- True Positive: %d\n', CM(1,1));
    fprintf('- True Negative: %d\n', CM(2,2));
    fprintf('- False Positive: %d\n', CM(1,2));
    fprintf('- False Negative: %d\n', CM(2,1));
    fprintf('- Accuracy: %f\n', accuracy(CM));
    fprintf('- Precision: %f\n', precision(CM));
    fprintf('- Recall: %f\n', recall(CM));
    fprintf('- F1-score: %f\n', f1_score(CM));
end
