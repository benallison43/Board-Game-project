%% Clear workspace and command window
clear
clc
%% Look to see what cameras are avaialble
camList = webcamlist;

%% Select the webcam you want to use
webcam = webcam(2); %change this to reflect which camera you want to use
%% Preview what the camera sees
preview(webcam)
%% Take a picture with the camera
pause(2) %Give camera time to turn on
picture = snapshot(webcam); %Take a picture
imshow(picture); %Show the picture
imwrite(picture,"Selfie.jpg"); %Save the picture to be able to submit it
%% Use a countdown to get ready for your selfie
for CountDown = 10:-1:1
    disp(CountDown)
    pause(1)
end
disp("SMILE!")
pause(1)
selfie = snapshot(webcam); %Take a picture
imshow(selfie); %Show the picture
imwrite(selfie,"Selfie.jpg"); %Save the picture to be able to submit it