%%PLOTTING THE CENTER AND THE Rectangle OF THE BOX
%% inputs_      im : the image snapshot from the conveyor
%% outputs_     
function plotBoxConv(im)
    I2 = im;
    I2 = pizza(im); 
    I2(:, 1:235) = 0;
    I2(1:117, :) = 0;
    I2(360:end, :) = 0;

    k = bwareaopen(I2,100);
    k = bwconvhull(k,'object');
    k = bwareaopen(k,100); 
    k = imclose(k,ones(2, 2));
    k = imopen(k,ones(3, 3));
    k = bwareaopen(k,1000);
    
% %     Directing to the specific handles.axes  
    s = regionprops(k,'orientation','centroid');
    for i=1:100
        if i>length(s)
            break;
        end
        cT = cos(s(i).Orientation/180*pi);
        sT = sin(s(i).Orientation/180*pi);   
        xs = [70, 70, -70, -70, 70];
        ys = [38, -38, -38, 38, 38];
        rec = [cT , sT; -sT, cT]*[xs;ys]+...
            [s(i).Centroid' s(i).Centroid' s(i).Centroid' s(i).Centroid' s(i).Centroid'];
        plot(s(i).Centroid(1),s(i).Centroid(2),'ro');
        plot(rec(1,:),rec(2,:),'g');
    end
end

%%
function [BW,maskedRGBImage] = pizza(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder App. The colorspace and
%  minimum/maximum values for each channel of the colorspace were set in the
%  App and result in a binary mask BW and a composite image maskedRGBImage,
%  which shows the original RGB image values under the mask BW.

% Auto-generated by colorThresholder app on 19-Apr-2015
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.000;
channel1Max = 1.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.069;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.000;
channel3Max = 0.646;

% Create mask based on chosen histogram thresholds
BW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);

% Invert mask
BW = ~BW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

