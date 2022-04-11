clear
close all

%%

img = imread("2.png");
img = im2bw(img, 0.5);
img_shrinking = bwmorph(img, "shrink", inf);
img_thinning = bwmorph(img, "thin", inf);
img_skeleton = bwmorph(img, "skeleton", inf);

%%
imshow(img_thinning);