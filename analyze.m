% matlab

printf('Loading image ...\n');
I = imread('satellite.jpg');

HSV = rgb2hsv(I);
H = HSV(:,:,1);
S = HSV(:,:,2);
V = HSV(:,:,3);

H_mean = mean(reshape(H, 1, []))
H_std = std(reshape(H, 1, []))

S_mean = mean(reshape(S, 1, []))
S_std = std(reshape(S, 1, []))

V_mean = mean(reshape(V, 1, []))
V_std = std(reshape(V, 1, []))

