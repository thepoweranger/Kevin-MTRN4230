%%%PLOTTING THE CENTER AND THE Rectangle OF THE BOX
%%% inputs_      im : the image snapshot from the conveyor
%%% outputs_  
%   c  : [ X, Y, theta]; of the box
%   d{'box number'}  : a struc of data about the 4 region in the box
%       .xy('region',:) : [X Y], centers of the 4 regions
%       .rec{'region'}  : [X X X X X;Y Y Y Y Y],parameter of the region
%       .theta{'box'}   : the angle of the REGIONS in the box

function [c, d] = plotBoxConv(im)
    c = [];
    d = {};
    theta = 0;
    I2 = im;
    % masking the image so that the boxes can be clearly detected
    I2 = convMask(im); 
    % focus the detection only to the conveyer parts of the image
    I2(:, 1:235) = 0;
    I2(1:117, :) = 0;
    I2(360:end, :) = 0;

    % removing the unwanted area(base on size)
    k = bwareaopen(I2,100);
    k = bwconvhull(k,'object');
    k = bwareaopen(k,100); 
    k = imclose(k,ones(2, 2));
    k = imopen(k,ones(3, 3));
    k = bwareaopen(k,1000);
    
    %finding the centroid and orientation of each box
    s = regionprops(k,'orientation','centroid');
    
    %Plotting the box. one box per loop upto 20 boxes
    for i=1:20
        if i>length(s)
            break;
        end
        X = (s(i).Centroid(1));
        Y = (480-s(i).Centroid(2));%%%%%%%%%%%%%%%%%%%%%%
        theta = s(i).Orientation/180*pi;
        cT = cos(theta);
        sT = sin(theta);   
        
        % parameters of the box
%         xs = [68, 68, -68, -68, 68];
%         ys = [38, -38, -38, 38, 38];
%         rec = [cT , sT; -sT, cT]*[xs;ys]+...
%             [s(i).Centroid' s(i).Centroid' s(i).Centroid' s(i).Centroid' s(i).Centroid'];
%         rec(2,:) = 480 - rec(2,:);%%%%%%%%%%%%%%%%%%%
%         plot( X, Y,'ro');
%         plot(rec(1,:),rec(2,:),'g');

        c(i,:) = [ X, Y, theta];
        d{i}.xy(1,:) = round([X-(51*cT), Y-(51*sT)]);
        d{i}.xy(2,:) = round([X-(17*cT), Y-(17*sT)]);
        d{i}.xy(3,:) = round([X+(17*cT), Y+(17*sT)]);
        d{i}.xy(4,:) = round([X+(51*cT), Y+(51*sT)]);
        plot(d{i}.xy(:,1), d{i}.xy(:,2), 'ro');hold on;
        
        d{i}.theta = -theta ;  
        
        cT = cos(-theta);
        sT = sin(-theta);   
        xr = [17, 17, -17, -17, 17];
        yr = [38, -38, -38, 38, 38];
        for p =1:4
            d{i}.rec{p} = [cT , sT; -sT, cT]*[xr;yr]+...
                [ d{i}.xy(p,:)', d{i}.xy(p,:)', d{i}.xy(p,:)',...
               d{i}.xy(p,:)', d{i}.xy(p,:)'];
           plot(d{i}.rec{p}(1,:), d{i}.rec{p}(2,:), 'g');
        end
    end
return
end


%%  The mask
function [BW,maskedRGBImage] = convMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder App.

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
return
end

