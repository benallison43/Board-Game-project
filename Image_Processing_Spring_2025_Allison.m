%{
Image Processing HEADER COMMENT 
Authors: Ben Allison

Assignment: EGR 103-8/9 Week 8 In class assignment
Date Changed: 3-5-25  

History:    Edited from R.Sellin adaptation of D.Francis Original
Purpose:    Code for Image Processing Code Along in EGR 103
%}
clc
clear
close all
%% Step 1: Bring in the Image
% Read in the image that we'll work with for the code along
boardHoming = imread('Homing Picture Example.jpg');

% Show the image
imshow(boardHoming)

%% Step 2: Example of How to Crop an Image (Not Necessary for Assignment, but good to know)
% Show the image you want to crop

% In the image you shown, the following line of code will allow you to
% click and drag a rectangle over the area you want cropped. Click and drag
% where you want to crop and the pixel coordinates for cropping the image
% will be saved to "Cropping". The coordinates are laid out as follows: 
% [XMIN YMIN WIDTH HEIGHT], where XMIN and YMIN are the X and Y coordinates
% of the top left corner of your rectangle, respectively, the WIDTH is
% the width of the rectangle in pixels, and HEIGHT is the height of the
% rectangle in pixels.

% imshow(boardHoming)
% Cropping = round(getPosition(imrect));
% disp(Cropping)

%% Step 3: Save Your Cropping Coordinates so MATLAB crops at the same location every time
% If your camera is permanently mounted to your game board, then you will
% likely be cropping the same area in the picture each time the picture is
% taken. If your camera is mounted, you can just save your cropping
% coordinates to a new variable and then have MATLAB crop those coordinates
% everytime it runs the code. Just copy and paste the rectangle coordinates
% into an array like shown below (these coordinates will be different for
% your real game)
Cropping_Permanent = [2 170 187 225];  

%                    [XMIN YMIN WIDTH HEIGHT]
% Tell MATLAB where to crop the image using the cropping coordinates you
% found
Cropped_boardHoming = imcrop(boardHoming,Cropping_Permanent);

imtool(Cropped_boardHoming)
%% Step 4: Split the image into Red, Green, and Blue channels
r_channel=Cropped_boardHoming(:,:,1);
g_channel=Cropped_boardHoming(:,:,2);
b_channel=Cropped_boardHoming(:,:,3);
%% Step 5: Calculate ratios between individual colors
RG_Ratio = double(r_channel)./double(g_channel); %Red/Green Ratio
RB_Ratio = double(r_channel)./double(b_channel); %Red/Blue Ratio
GB_Ratio = double(g_channel)./double(b_channel); %Green/Blue Ratio
% Now we look at the ratios
RG_Ratio(isnan(RG_Ratio))=0; %If the Red/Green ratio is NaN, set it to 0
RB_Ratio(isnan(RB_Ratio))=0; %If the Red/Blue ratio is NaN, set it to 0
GB_Ratio(isnan(GB_Ratio))=0; %If the Green/Blue ratio is NaN, set it to 0
%% Use imtool() and Excel (or another method) to find RGB values for areas of interest
imtool(Cropped_boardHoming)
%% Step 7: Use ratios to differentiate between things in the image
% determine a disciminant
figure
Found_Stickers = (RG_Ratio <= 0.25);

imshow(Found_Stickers);
%% Step 8: Clean up the image so only the stickers remain
% We see that we found the stickers, but also included some of the other
% green part of the game board. We can remove that from our found image 
% using bwareaopen, which removes chunks of found pixels less than a given
% area (in pixels). 
Stickers_Cleaned = bwareaopen(Found_Stickers,1000);

imshow(Stickers_Cleaned)
%% Step 9: If you have holes in whatever you found, you can fill them in
% (May Not be Necessary for your vision system, just an example here)
Stickers_Filled = imfill(Stickers_Cleaned,"holes");
imshow(Stickers_Filled)
%% Step 10 (Optional): Overlay a color over what you found in your image
% Sometimes it helps to have MATLAB overlay colors on what you found
% through image processing in order to troubleshoot. In this example (which
% is not necessary for the assignment), we'll overlay BLUE on top of
% whatever we found
blue_Overlay = imoverlay(Cropped_boardHoming,Stickers_Filled,[0,0,1]);

imshow(blue_Overlay)
%% Step 11: Find the Centroids of your stickers
% Use "regionprops" to find the centroids (i.e., the centers) of our
% stickers. Effectively, regionprops looks at the white blobs (the areas of
% white pixels) and determines the centroids (or whatever else you may
% want). This is why it was important to remove the white blobs that we
% didn't care about!
Centroids = regionprops('table',Stickers_Filled,'Centroid');
Centroids = Centroids{:,:};
%Show the centroids
figure, imshow(Cropped_boardHoming), title('Centroids for Alignment Stickers')
hold on
    plot(Centroids(:,1),Centroids(:,2),'r+','MarkerSize',10,'LineWidth',2);
hold off 
%% Step 12: Find the Distance Between the Centroids (Assignment Submission)
% We're going to use the formula for distance between two points to find
% the distance between the two centroids in pixels. The formula is: square
% root((X_1-X_2)^2+(Y_1-Y_2)^2)
Centroid_Distance = sqrt((Centroids(1,1)-Centroids(2,1))^2+(Centroids(1,2)-Centroids(2,2))^2);

fprintf('The distance between centroids is %.2f pixels \n',Centroid_Distance);
%% Step 13: Look at Bounding Boxes
% If we find that our game board is out of home, like it is in the example
% image, then we need to be able to tell the stepper motor how to correct
% it (i.e., how to get back to home). Before doing that, we need to know
% the distance in something other than pixels. So, we'll find a pixel to
% unit conversion using bounding boxes and a known distance on our game
% board.

% Bounding boxes are a function of regionprops, just like centroids. In
% this case, bounding boxes place a box around each of the white blobs in
% our found pictures. We can then use the bounding boxes to help get a
% conversion factor

Bounding_Boxes = regionprops('table',Stickers_Filled, 'BoundingBox');
Bounding_Boxes = Bounding_Boxes{:,:};
figure, imshow(Cropped_boardHoming),title('Bounding Boxes Around Stickers')
hold on
    for k = 1:size(Bounding_Boxes,1) % for k = 1:# of rows in Bounding_Box array
        Sticker_Bounding = Bounding_Boxes(k,:);%.BoundingBox;
        rectangle('Position',Sticker_Bounding,'EdgeColor','r','LineWidth',1) %Plots bounding boxes on image
    end
hold off

%% Step 14: Look at an Example Bounding Box Table

imshow("Example_Bounding_Box_Table.jpg")

%% Step 15: Use Bounding Boxes to get a Conversion Factor

% The way the bounding box array is set up is it typically lists bounding
% box information for each box in order from left to right in the image.
% For this example, the first row of the bounding box array would
% correspond to the left most bounding box while the second row corresponds
% to the right most box. The row location of your bounding box will likely
% change when you develop the vision system for your board, so make sure to
% verify you have the correct box called out in the code.

% We will use the width in the X-Direction of the second bounding box (in
% row two). 

Width_in_Pixels = Bounding_Boxes(2,3); 
% I know the width of my larger alignment sticker is 1 inch, so I can use
% that knowledge to develop a pixel to unit (inches in this case)
% conversion.
Width_in_inches = 1; % Larger alignment sticker is 1 inch long
Conversion_Factor = Width_in_inches/Width_in_Pixels; 
% Display the conversion factor (you don't need to do this in your game
% board code)
fprintf('The conversion factor is %.4f inches per pixel \n',Conversion_Factor);

%% Step 16: Find the Distance the Stepper Needs to Move to Get Back to Home

% An easy way to get your game board back to home in this example would be
% to get the centroids to be at the same Y-coordinate (meaning that 
% they're in line with each other). We have the X and Y-coordinates for the
% centroids, and have a conversion factor from pixels to inches. So, we can
% find how far to move the game board to get it back to home.

% Find the distance in the Y-direction between the two centroids
Centroid_Y_Distance_Pixels = Centroids(2,2) - Centroids(1,2);

% Display the distance (you don't need to do this in your game board code)
fprintf('The Y-Distance between the centroids is %.2f pixels \n',Centroid_Y_Distance_Pixels);

% Convert the Y-Distance from Pixels to Inches using the conversion

Y_Distance_Inches = Centroid_Y_Distance_Pixels*Conversion_Factor;

% Display the distancein inches (you don't need to do this in your game board code)
fprintf('The Y-Distance between the centroids is %.2f inches \n',Y_Distance_Inches);

% So, now you know the actual unit of distance (rather than just pixels)
% that your game board needs to be moved in order to be properly homed. The
% distance your stepper will need to move in order to achieve this will be
% a function of the size of the board that you are using as well as the
% gear ratios between the stepper and whichever part of your board is being
% rotated.

