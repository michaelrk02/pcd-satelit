% matlab

printf('Loading image ...\n');
I = imread('satellite.jpg');

HSV = rgb2hsv(I);
H = HSV(:,:,1);
S = HSV(:,:,2);
V = HSV(:,:,3);

V = 0.5 * V;

I = hsv2rgb(cat(3, H, S, V));
imwrite(I, 'satellite-dark.jpg');

printf('Image saved\n');
