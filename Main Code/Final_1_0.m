clear all; close all; clc;

%% Openning the Nifti file, extracting the image that can be analyzed and reorganizing as shown in the Nifit file.
[filename, pathname] = uigetfile({'*.nii.gz'},'Pick a file');        
file = strcat(pathname, filename);
data = load_nii(file);
image_4d = data.img;
[x,y,z,t] = size(image_4d);
disp(z);
image_1D = image_4d(:,:,3);
image_1D_rotate = imrotate(image_1D,270);
image_1D_mirror = flipdim(image_1D_rotate,2);

%% Finding the center of the Image
[rows columns numberOfColorChannels] = size(image_1D_mirror);
y_center = rows / 2;
x_center = columns / 2;
croppedImage = imcrop(image_1D_mirror, [x_center-45 y_center-45 90 90]);

%% Quantization(Binarization) using Otsu's Threshold
level = multithresh(croppedImage);
im_quantized = imquantize(croppedImage, level);

%% Canny Edge detection
canny_edged = edge(im_quantized,'canny');

%% Dilation to increase the detection border
diskElem = strel('line',3,3);
Img = imdilate(canny_edged, diskElem);

%% clearing the elements at the border
border_cleared = imclearborder(Img);

%% filing the center elements to creat blobs
Blobs = imfill(border_cleared,'holes');

%% Deleting all blobs less than 500 pixels(total image=1101 pixels), biggest blob is the binary mask.
Biggest_Blob = bwareaopen(Blobs,300);
figure;
imshow(Biggest_Blob);
title('Obtained binary mask');

%% Finding the boundary infromation of the mask
[B,L]=bwboundaries(Biggest_Blob,'noholes');

%% Dice Score;
[filename2, pathname2] = uigetfile({'*.nii.gz'},'Pick the ground truth file');        
file2 = strcat(pathname2, filename2);
data2 = load_nii(file2);
image_4d2 = data2.img;
[x2,y2,z2,t2] = size(image_4d);
disp(z2);
image_1D2 = image_4d2(:,:,3);
image_1D_rotate2 = imrotate(image_1D2,270);
image_1D_mirror2 = flipdim(image_1D_rotate2,2);
[rows2 columns2 numberOfColorChannels2] = size(image_1D_mirror2);
y_center2 = rows2 / 2;
x_center2 = columns2 / 2;
croppedImage2 = imcrop(image_1D_mirror2, [x_center2-45 y_center2-45 90 90]);
figure;
imshow(croppedImage2,[]);
title('Ground truth');
endocard = max(croppedImage2,2.1);
binarized2 = imbinarize(endocard);
figure;
imshow(binarized2,[]);
title('Ground truth for the endocardial border');
dice = (2*nnz(Biggest_Blob&binarized2))/(nnz(Biggest_Blob)+nnz(binarized2));
disp(dice);

%% Printing all the segmentation images
figure;
subplot(3,2,[1,3,5]);
imshow(image_1D_mirror,[]);
title('The image extracted from Nifti file');

subplot(3,2,2);
imshow(croppedImage,[]);
title('The ROI');

subplot(3,2,4);
imshow(Biggest_Blob,[]);
title('The binary mask to detect the LV');

subplot(3,2,6);
imshow(croppedImage,[]);
hold on
for i=1:length(B)
    plot(B{i}(:,2),B{i}(:,1), 'r' ,'linewidth',1.45);
end
title('Detected LV');
hold off;