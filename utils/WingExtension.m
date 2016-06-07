function [WE_score,WE_is] = WingExtension(fly_apart_error,fly_body, fly_with_wing,  initial_body_area,initial_wing_area,initial_body_MajorAxisLength,initial_body_MinorAxisLength,ROIs,frame)
%WINGEXTENSION Summary of this function goes here
%   Detailed explanation goes here
if fly_apart_error > 0
    %disp('fly_apart_error')
    WE_score = [NaN NaN];
    WE_is = [NaN NaN];
    return
end

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
    WE_score = [NaN NaN];
    %keyboard
    return
end



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
    WE_score_1 = (area_1_upper - area_1_lower)/(area_1_upper + area_1_lower);
end

if area_2_upper + area_2_lower ==0
    WE_score_2 = 0;
else
    WE_score_2 = (area_2_upper - area_2_lower)/(area_2_upper + area_2_lower);
end



if (dist_b1_w1+dist_b2_w2) < (dist_b1_w2 + dist_b2_w1)
    WE_score = [WE_score_1,WE_score_2];
    
    if abs(WE_score_1)>0.5 && max(area_1_upper, area_1_lower)>0.2 * max(initial_body_area)
        WE_is_1 = 1;
    end
    
    if abs(WE_score_2)>0.5 && max(area_2_upper, area_2_lower)>0.2 * max(initial_body_area)
        WE_is_2 = 1;
    end
    
    WE_is = [WE_is_1,WE_is_2];
    
    
else
    WE_score = [WE_score_2,WE_score_1];
    
    if abs(WE_score_1)>0.2 && max(area_1_upper, area_1_lower)>0.2 * max(initial_body_area)
        WE_is_2 = 1;
    end
    
    if abs(WE_score_2)>0.2 && max(area_2_upper, area_2_lower)>0.2 * max(initial_body_area)
        WE_is_1 = 1;
    end
    
    WE_is = [WE_is_1,WE_is_2];
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






% if WE_is(2) == 1 || WE_is(1) == 1
%     imshow(flies_with_wings);
%     
%     beep;
%     keyboard;
% end
end



% % Get upper and lower half of the fly (divided by major axis). ---end
% 
% 
% % Calculate Asymmetry
% % Get the bboundary of the half fly, calculate the distance between each point and normalized major axis vector
% 
% if any(any(fly_1_upper))
%     dist_1_upper = bd2line_dist( fly_1_upper, x1y1_body, x1ay1a_body);
%     dist_1_upper_top20_mean = mean(dist_1_upper(1:min(20,size(dist_1_upper))));
% end
% 
% if any(any(fly_1_lower))
%     dist_1_lower = bd2line_dist( fly_1_lower, x1y1_body, x1ay1a_body);
%     dist_1_lower_top20_mean = mean(dist_1_lower(1:min(20,size(dist_1_lower))));
% end
% 
% if any(any(fly_2_upper))
%     dist_2_upper = bd2line_dist( fly_2_upper, x2y2_body, x2ay2a_body);
%     dist_2_upper_top20_mean = mean(dist_2_upper(1:min(20,size(dist_2_upper))));
% end
% 
% if any(any(fly_2_lower))
%     dist_2_lower = bd2line_dist( fly_2_lower, x2y2_body, x2ay2a_body);
%     dist_2_lower_top20_mean = mean(dist_2_lower(1:min(20,size(dist_2_lower))));
% end

    % Get mask for each fly to seperate them --- Start
%     mask_fly_1 = zeros(480,640);
%     mask_fly_2 = zeros(480,640);
%     
%     bbx1_UL = rp_with_wings(1).BoundingBox(1);
%     bby1_UL = rp_with_wings(1).BoundingBox(2);
%     bbx1_LR = rp_with_wings(1).BoundingBox(1)+rp_with_wings(1).BoundingBox(3);
%     bby1_LR = rp_with_wings(1).BoundingBox(2)+rp_with_wings(1).BoundingBox(4);
%     
%     bbx2_UL = rp_with_wings(2).BoundingBox(1);
%     bby2_UL = rp_with_wings(2).BoundingBox(2);
%     bbx2_LR = rp_with_wings(2).BoundingBox(1)+rp_with_wings(2).BoundingBox(3);
%     bby2_LR = rp_with_wings(2).BoundingBox(2)+rp_with_wings(2).BoundingBox(4);
%     
%     
%     for x = uint16(bbx1_UL-1):uint16(bbx1_LR+1)
%         for y = uint16(bby1_UL-1):uint16(bby1_LR+1)
%             mask_fly_1(y,x)=1; %Note: the x,y is revesed in matrix, compare to a image
%         end
%     end
%     
%     for x = uint16(bbx2_UL-1):uint16(bbx2_LR+1)
%         for y = uint16(bby2_UL-1):uint16(bby2_LR+1)
%             mask_fly_2(y,x)=1;
%         end
%     end
%     
%     fly_1_with_wings = flies_with_wings.*mask_fly_1;
%     fly_2_with_wings = flies_with_wings.*mask_fly_2;

