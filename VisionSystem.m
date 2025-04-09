
% Image Processing HEADER COMMENT 
% Authors: Ben Allison
% 
% Assignment: EGR 103-8/9 Week 8 dice check POC 2
% Date Changed: 3-6-25
% 
% History:    Edited from R.Sellin adaptation of D.Francis Original
% Purpose:    Code for Image Processing Code Along in EGR 103


clc;
clear;
close all;

% Camera Setup and Image Capture
% camName = 'USB Camera';             % Use the exact name from webcamlist
% webcamObj = webcam(camName);        % Select by name to deal with a Mac bug
% pause(2);               % Allow the camera to initialize
% picture = snapshot(webcamObj);
% imwrite(picture, "Vision.jpg");

% Load and Display Original Image
boardHoming = imread("Vision.jpg");
imshow(boardHoming);
title("Original Image");

%Okay so thiis part detects a whit object and crops to it as a homing crop.
%

% --- White Dice Detection Parameters (Adjust these as needed) ---
whiteThreshold = 180;  % <-- Adjust this value to change what is considered "white"
tolerance = 10;        % <-- Adjust this for how close R, G, B need to be (smaller = stricter)
minWhiteRegion = 200;  % <-- Min pixel area for a white region to count

% Detect White Die Region Automatically
r = double(boardHoming(:,:,1));
g = double(boardHoming(:,:,2));
b = double(boardHoming(:,:,3));

whiteMask = (r > whiteThreshold) & (g > whiteThreshold) & (b > whiteThreshold) & ...
            (abs(r - g) < tolerance) & (abs(r - b) < tolerance) & (abs(g - b) < tolerance);

whiteMask = bwareaopen(whiteMask, minWhiteRegion);
whiteMask = imfill(whiteMask, 'holes');

stats = regionprops(whiteMask, 'BoundingBox', 'Area');


[~, idx] = max([stats.Area]);
dieBox = stats(idx).BoundingBox;

shrinkPixels = 5;  % Try 5–10 for small tightening
dieBox(1) = dieBox(1) + shrinkPixels;
dieBox(2) = dieBox(2) + shrinkPixels;
dieBox(3) = dieBox(3) - 2 * shrinkPixels;
dieBox(4) = dieBox(4) - 2 * shrinkPixels;


% Crop to Detected Dice Region
Cropped_boardHoming = imcrop(boardHoming, dieBox);
figure, imshow(Cropped_boardHoming);
title("Cropped to White Die");

% (Optional: Comment this back in if i want to test manual cropping instead)
% Cropping_Permanent = [262,226,60,54];
% Cropped_boardHoming = imcrop(boardHoming, Cropping_Permanent);

% Begin Sticker Detection (Refined but minimal changes)
% Begin Sticker Detection (Tweaked for cleaner blobs)
r = Cropped_boardHoming(:,:,1);
g = Cropped_boardHoming(:,:,2);
b = Cropped_boardHoming(:,:,3);

% Convert to double for safe ratio calculations
r = double(r);
g = double(g);
b = double(b);

% Ratio filters (tightened)
RG = r ./ (g + eps);
RB = r ./ (b + eps);
GB = g ./ (b + eps);

% Dark pixel filter (stricter to avoid fuzzy highlights)
intensity = (r + g + b) / 3;
%darkMask = intensity < 140;  % was 100 — now tighter
darkMask = intensity < 200;  % was above - may need to reduce  

%HERE HERE HERE HEERE HERE HERE LOOKKK HEREEEEEE DON'T BE A FOOL AND LOOK
%For future me trying to figure out a problem. It is the line above. 


% Combined logic: focus on dark, low-red areas
Found_Stickers = (RG <= 1.15) & (RB <= 1.15) & darkMask;

figure, imshow(Found_Stickers);
title("Initial Sticker Detection");

% Clean up and isolate blobs
Stickers_Cleaned = bwareaopen(Found_Stickers, 15);  % Filter tiny noise
Stickers_Cleaned = imclose(Stickers_Cleaned, strel('disk', 5));  % Light closing only

figure, imshow(Stickers_Cleaned);
title("Cleaned Sticker Mask");

% Fill small holes inside blobs
Stickers_Filled = imfill(Stickers_Cleaned, "holes");

figure, imshow(Stickers_Filled);
title("Hole-Filled Mask");

% Bounding boxes for display
Bounding_Boxes = regionprops('table', Stickers_Filled, 'BoundingBox');
Bounding_Boxes = Bounding_Boxes{:,:};

figure, imshow(Cropped_boardHoming);
title("Bounding Boxes Around Detected Stickers");
hold on;
for k = 1:size(Bounding_Boxes,1)
    rectangle('Position', Bounding_Boxes(k,:), 'EdgeColor', 'r', 'LineWidth', 1);
end
hold off;

dicenum = k;
