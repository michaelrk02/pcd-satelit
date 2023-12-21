function k = label_to_segment(color)
    if norm(color - [0.33 1.0 1.0]) < 0.05
        k = 1;
    elseif norm(color - [0.0 1.0 1.0]) < 0.05
        k = 2;
    elseif norm(color - [0.67 1.0 1.0]) < 0.05
        k = 3;
    else
        k = 0;
    end
end
