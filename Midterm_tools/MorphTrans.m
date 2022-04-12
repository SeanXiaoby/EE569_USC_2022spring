clear
close all

%%

img = imread("3.png");
img = 1-im2bw(img, 0.5);
img_shrinking = bwmorph(img, "shrink", inf);
% img_thinning = bwmorph(img, "thin", inf);
% img_skeleton = bwmorph(img, "skeleton", inf);

%%
figure
imshow(img_shrinking);
figure
imshow(img_thinning);
figure
imshow(img_skeleton);

