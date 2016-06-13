function [distant_wing_area,WE_is] = WingExtension(fly_apart_error,fly_body, fly_with_wing,  initial_body_area,initial_wing_area,initial_body_MajorAxisLength,initial_body_MinorAxisLength,ROIs,frame)
%WINGEXTENSION Summary of this function goes here
%   Detailed explanation goes here
if fly_apart_error > 0
    %disp('fly_apart_error')
    distant_wing_area = [NaN NaN NaN NaN];
    WE_is = [NaN NaN];
    return
end

RATIO = 4.4971;
MIN_AREA_RATIO = 0.1895;

WE_is_1 = 0;
WE_is_2 = 0;
WE_is = [0 0];
rp_with_wings = regionprops(logical(fly_with_wing),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
rp_body = regionprops(logical(fly_body),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');


if length(rp_body)==2 && length(rp_with_wings) == 2
    % Get flies' majoraxis vector --- Start
    pos_1_body = rp_body(1).Centroid;
    pos_2_body = rp_body(2).Centroid;
    pos_1_wing = rp_with_wings(1).Centroid;
    pos_2_wing = rp_with_wings(2).Centroid;
    
    pos_b1_w1 = [pos_1_body(1),pos_1_body(2);pos_1_wing(1),pos_1_wing(2)];
    pos_b2_w2 = [pos_2_body(1),pos_2_body(2);pos_2_wing(1),pos_2_wing(2)];
    pos_b1_w2 = [pos_1_body(1),pos_1_body(2);pos_2_wing(1),pos_2_wing(2)];
    pos_b2_w1 = [pos_2_body(1),pos_2_body(2);pos_1_wing(1),pos_1_wing(2)];
    
    dist_b1_w1 = pdist(pos_b1_w1,'euclidean');
    dist_b2_w2 = pdist(pos_b2_w2,'euclidean');
    dist_b1_w2 = pdist(pos_b1_w2,'euclidean');
    dist_b2_w1 = pdist(pos_b2_w1,'euclidean');
    
    if (dist_b1_w1+dist_b2_w2) < (dist_b1_w2 + dist_b2_w1)
        x1y1_body=rp_body(1).Centroid; %centroid must be on the major axis
        x2y2_body=rp_body(2).Centroid;
        x1ay1a_body = [x1y1_body(1)+cos(-rp_body(1).Orientation*pi/180),x1y1_body(2)+sin(-rp_body(1).Orientation*pi/180)]; %The other poinit is calculated with orientation
        x2ay2a_body = [x2y2_body(1)+cos(-rp_body(2).Orientation*pi/180),x2y2_body(2)+sin(-rp_body(2).Orientation*pi/180)];
        
        
        k1 = tan(-rp_body(1).Orientation*pi/180);
        cos1 = cos(-rp_body(1).Orientation*pi/180);
        b1 = x1y1_body(2)-k1*x1y1_body(1);
        
        k2 = tan(-rp_body(2).Orientation*pi/180);
        cos2 = cos(-rp_body(2).Orientation*pi/180);
        b2 = x2y2_body(2)-k2*x2y2_body(1);
        
    else %When the regions ID in rp_body rp_with wings are inversed
        x1y1_body=rp_body(2).Centroid; %centroid must be on the major axis
        x2y2_body=rp_body(1).Centroid;
        x1ay1a_body = [x1y1_body(1)+cos(-rp_body(2).Orientation*pi/180),x1y1_body(2)+sin(-rp_body(2).Orientation*pi/180)]; %The other poinit is calculated with orientation
        x2ay2a_body = [x2y2_body(1)+cos(-rp_body(1).Orientation*pi/180),x2y2_body(2)+sin(-rp_body(1).Orientation*pi/180)];
        
        
        k1 = tan(-rp_body(2).Orientation*pi/180);
        cos1 = cos(-rp_body(2).Orientation*pi/180);
        b1 = x1y1_body(2)-k1*x1y1_body(1);
        
        k2 = tan(-rp_body(1).Orientation*pi/180);
        cos2 = cos(-rp_body(1).Orientation*pi/180);
        b2 = x2y2_body(2)-k2*x2y2_body(1);
    end
    

    
    % Separate the two flies into two bw images.
    fly_with_wings_larger = bwareafilt(logical(fly_with_wing),1);
    fly_with_wings_smaller = bwareafilt(logical(fly_with_wing),1,'smallest');
    
    if rp_with_wings(1).Area > rp_with_wings(2).Area
        fly_1_with_wings = fly_with_wings_larger;
        fly_2_with_wings = fly_with_wings_smaller;
    elseif rp_with_wings(1).Area < rp_with_wings(2).Area
        fly_2_with_wings = fly_with_wings_larger;
        fly_1_with_wings = fly_with_wings_smaller;
    elseif rp_with_wings(1).Area == rp_with_wings(2).Area %It must be super unlikely.
        rp_larger = regionprops (logical(fly_with_wings_larger),'Centroid');
        
        pos_larger = rp_larger.Centroid;

        pos_1_wing = rp_with_wings(1).Centroid;
        pos_2_wing = rp_with_wings(2).Centroid;
        
        pos_larger_w1 = [pos_larger(1),pos_larger(2);pos_1_wing(1),pos_1_wing(2)];
        pos_larger_w2 = [pos_larger(1),pos_larger(2);pos_2_wing(1),pos_2_wing(2)];
        
        dist_larger_w1 = pdist(pos_larger_w1,'euclidean');
        dist_larger_w2 = pdist(pos_larger_w2,'euclidean');
        
        if dist_larger_w1<dist_larger_w2,
            fly_1_with_wings = fly_with_wings_larger;
            fly_2_with_wings = fly_with_wing.*(~fly_1_with_wings);
        else
            fly_2_with_wings = fly_with_wings_larger;
            fly_1_with_wings = fly_with_wing.*(~fly_2_with_wings);
        end
    end
else
    fprintf('body~=2 or wings~=2 in frame %d',frame)
    distant_wing_area = [NaN NaN];
    return
end



% Create a mask that can remove all pixles within 1.2*MinorAxisLength of
% major axis (If no wing extension, all area will be removed)

mask_1_upper = zeros(480,640);
mask_1_lower = zeros(480,640);


for x = 1:640
    y_upper = k1*x+b1+1.2*min(initial_body_MinorAxisLength)/cos1;
    y_lower = k1*x+b1-1.2*min(initial_body_MinorAxisLength)/cos1;
    
    for y = max(uint16(y_upper),1):480
        mask_1_lower(y,x)=1;
    end
    for y = 1:min(uint16(y_lower),480)
        mask_1_upper(y,x)=1;
    end
end

fly_1_upper = fly_1_with_wings & mask_1_upper;
rp_1_upper= regionprops(fly_1_upper,'Area');

fly_1_lower = fly_1_with_wings & mask_1_lower;
rp_1_lower= regionprops(fly_1_lower,'Area');


% Let's do fly 2.
mask_2_upper = zeros(480,640);
mask_2_lower = zeros(480,640);

for x = 1:640
    y_upper = k2*x+b2+1.2*min(initial_body_MinorAxisLength)/cos2;
    y_lower = k2*x+b2-1.2*min(initial_body_MinorAxisLength)/cos2;
    
    for y = max(uint16(y_upper),1):480
        mask_2_lower(y,x)=1;
    end
    for y = 1:min(uint16(y_lower),480)
        mask_2_upper(y,x)=1;
    end
end

fly_2_upper = fly_2_with_wings & mask_2_upper;
rp_2_upper= regionprops(fly_2_upper,'Area');

fly_2_lower = fly_2_with_wings & mask_2_lower;
rp_2_lower= regionprops(fly_2_lower,'Area');

%
%
%

if isempty(rp_1_upper)
    area_1_upper = 0;
else
    area_1_upper = max([rp_1_upper.Area]);
end
    
if isempty(rp_1_lower)
    area_1_lower = 0;
else
    area_1_lower = max([rp_1_lower.Area]);
end

if isempty(rp_2_upper)
    area_2_upper = 0;
else
    area_2_upper = max([rp_2_upper.Area]);
end

if isempty(rp_2_lower)
    area_2_lower = 0;
else
    area_2_lower = max([rp_2_lower.Area]);
end


if area_1_upper + area_1_lower ==0
    WE_score_1 = 0;
else
    WE_score_1 = max(area_1_upper, area_1_lower)/min(area_1_upper, area_1_lower);
end

if area_2_upper + area_2_lower ==0
    WE_score_2 = 0;
else
    WE_score_2 = max(area_2_upper, area_2_lower)/min(area_2_upper, area_2_lower);
end



if (dist_b1_w1+dist_b2_w2) < (dist_b1_w2 + dist_b2_w1)
    
    
    if WE_score_1>RATIO && max(area_1_upper, area_1_lower)>MIN_AREA_RATIO * mean(initial_body_area)
        WE_is_1 = 1;
    end
    
    if WE_score_2>RATIO && max(area_2_upper, area_2_lower)>MIN_AREA_RATIO * mean(initial_body_area)
        WE_is_2 = 1;
    end
    
    WE_is = [WE_is_1,WE_is_2];
    distant_wing_area = [area_1_upper,area_1_lower,area_2_upper,area_2_lower];
    
else
    
    if WE_score_1>RATIO && max(area_1_upper, area_1_lower)>MIN_AREA_RATIO * mean(initial_body_area)
        WE_is_2 = 1;
    end
    
    if WE_score_2>RATIO && max(area_2_upper, area_2_lower)>MIN_AREA_RATIO * mean(initial_body_area)
        WE_is_1 = 1;
    end
    
    WE_is = [WE_is_1,WE_is_2];
    distant_wing_area = [area_2_upper,area_2_lower,area_1_upper,area_1_lower];
end


% if too close to the wall, disgard the WE calculation, set to 0
if length(rp_body)==2
    pos_1_body = rp_body(1).Centroid;
    pos_2_body = rp_body(2).Centroid;

    pos_ROI = [ROIs(1) ROIs(2)];
    radius = ROIs(3);
    
    if radius - norm(pos_1_body-pos_ROI) < 0.5 * max(initial_body_MajorAxisLength)
        WE_is(1) = 0;
    end
    
    if radius - norm(pos_2_body-pos_ROI) < 0.5 * max(initial_body_MajorAxisLength)
        WE_is(2) = 0;
    end
    
elseif length(rp_body)==1
    pos_body = rp_body.Centroid;
    pos_ROI = [ROIs(1) ROIs(2)];
    radius = ROIs(3);
    if radius - norm(pos_body - pos_ROI) < 0.5 * max(initial_body_MajorAxisLength)
        WE_is = [0,0];
    end
end


end

