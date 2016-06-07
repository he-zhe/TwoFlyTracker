function [rp_body, rp_with_wing, fly_body, fly_with_wing] = get_flies(frame, background, channel, movie, thresh, mask)
%GET_FLIES Summary of this function goes here
%   Detailed explanation goes here

ff = read(movie,frame);
ff = ff (:,:,channel);
ff = ff.*mask;
flies = background - ff; %substract background, get flies

%thresh = multithresh (flies,2); %move this to core function
%Generate 2 thresholds, lower one for body+wing, higher for body only


fly_with_wing = flies; 
fly_with_wing(fly_with_wing<thresh(1)) = 0;
fly_with_wing(fly_with_wing>=thresh(1)) = 1;
fly_with_wing = im2bw(fly_with_wing,0); %Convert to bw
fly_with_wing = bwareaopen(fly_with_wing,400); %Only keep objects area larger than 400


fly_body = flies;
fly_body(fly_body<thresh(2)) = 0;
fly_body(fly_body>=thresh(2)) = 1;
fly_body = im2bw(fly_body,0);
fly_body = bwareaopen(fly_body,400);

rp_body = regionprops(fly_body,'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
rp_with_wing = regionprops(fly_with_wing,'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');

end

