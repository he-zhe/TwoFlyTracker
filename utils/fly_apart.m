function [fly_body, fly_with_wing, fly_apart_error, collision, min_body_dist ] = fly_apart( rp_body, rp_with_wing, fly_body, fly_with_wing, initial_body_area,initial_wing_area,initial_body_MajorAxisLength,frame )
%FLY_APART Summary of this function goes here
%   Detailed explanation goes here

%fly_apart_errors:
%0: OK
%8: No flies
%2: One fly is missing.
%3: Body cannot be separated
%9: Unknown
%5: shouldn't exist


% % To troubleshooting specific frame
% if frame == 614
%     disp('check the fly_apart_error here')
%     keyboard
% end


fly_with_wing_ori = fly_with_wing;
fly_body_ori = fly_body;

%remove holes
fly_with_wing = imfill(logical(fly_with_wing),'holes');
fly_body = imfill(logical(fly_body),'holes');

fly_apart_error = 0;
collision = 0;
min_body_dist = NaN;


%Create structual shapes, later used in imdilate(), imerode()
se = strel('disk',2);
se_small  = strel('disk',1);



% When more than 3 regions are detected, only select the top 2. Not manually
% checked yet.
if length(rp_body)>=3
    fly_body = bwareafilt(logical(fly_body),2);
    rp_body = regionprops(fly_body,'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
end

if length(rp_with_wing)>=3
    fly_with_wing = bwareafilt(logical(fly_with_wing),2);
    rp_with_wing = regionprops(fly_with_wing,'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
end


if isempty(rp_body)
    fprintf('fly_apart: No flies in frame %d\n',frame)
    fly_body = zeros(480,640);
    fly_with_wing = zeros(480,640);
    fly_apart_error = 8; %No flies
    return
elseif max([rp_body.Area]> 3*max(initial_body_area))
    fprintf('fly_apart: Too large body area are detected in frame %d\n',frame)
    fly_body = zeros(480,640);
    fly_with_wing = zeros(480,640);
    fly_apart_error = 2; 
    return
elseif sum([rp_with_wing.Area])> 4*max(initial_wing_area)
    fprintf('fly_apart: Too large wing area detected in frame %d\n',frame)
%     imshow(fly_with_wing);
%     keyboard;
    fly_body = zeros(480,640);
    fly_with_wing = zeros(480,640);
    fly_apart_error = 2; 
    return    
elseif length(rp_body)==2 && length(rp_with_wing) == 2 %Things are OK, no need to be further processed 
    min_body_dist = body_dist_appr(fly_body);
    return
elseif  length(rp_body)==1 && length(rp_with_wing) == 2
    fly_body = fly_with_wing;
    min_body_dist = body_dist_appr(fly_body);    
    return       
end


% If only one body is detected, and the area of the body is smaller than
% 1.5 initial body area. Only one of the two flies is recorded by the
% camera. Return flymissing
if length(rp_body) == 1 && ...
        (sum([rp_with_wing.Area]) <= 1.5*max(initial_wing_area) || sum([rp_body.Area]) <= 1.5*max(initial_body_area))...
        && sum([rp_body.MajorAxisLength])< 1.5*max(initial_body_MajorAxisLength)...
        
    fly_apart_error = 1; %missing fly
    fprintf('fly_apart: missing fly in frame %d\n',frame);
    min_body_dist = 0;
    %This part has been manually checked.
    return
end


if length(rp_body) == 1
    collision = 1;
    min_body_dist = 0;
elseif length(rp_body) == 2
    min_body_dist = body_dist_appr(fly_body);
end

    


% When only one body region is detected, try to use imerode to erode the region,
% aiming to disconnect the overlapped body region.
% In each of this while-loop, the body region is eroded, until seperation
% (len>1) or erode two small (measured by body areas)
while length(rp_body) == 1 && rp_body.Area > max(initial_body_area)
    fly_body = imerode(fly_body,se);
    rp_body = regionprops(logical(fly_body),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
end

if min([rp_body.Area]) < 0.25*min(initial_body_area) % The erosion results in a tiny area, fail
    fly_body = fly_body_ori;
    rp_body = regionprops(logical(fly_body),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
elseif length(rp_body) >2
    fly_body = bwareafilt(logical(fly_body),2);
    rp_body = regionprops(logical(fly_body),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
end

    


% If the number of the body regions is still one. Use this following
% method.
% Basically, it use the centroids and the (orientation + 90) to define a
% line. Use this line to create a mask and approximately separate the
% connected body.
if length(rp_body) == 1
%     imshow(flies_body);
    fprintf('fly_apart: After erosion, body region is still 1 in frame %d.\n', frame);
    
    x1y1=[rp_body.Centroid];
    % y = kx + b
    k = tan(-(rp_body(1).Orientation+90)*pi/180);
    b = x1y1(2)-k*x1y1(1);
    
    flies_body_precut = fly_body;
    
    mask_line_apart = ones(480,640);
    

    for x = 1:0.05:640
        upper_limit_y = max(min(max(uint16(k*x+b)-1,1),480),min(max(uint16(k*(x+1)+b)+1,1),480));
        lower_limit_y = min(min(max(uint16(k*x+b)-1,1),480),min(max(uint16(k*(x+1)+b)+1,1),480));
            % The max() limits the y >= 1.
            % The min() limits the y <= 480
            % So y is always within the range of the width of the video
            % frame
            % Use upper_y and lower_y to deal with k>0 and k<0 ++++++++
        for y = lower_limit_y:upper_limit_y

            mask_line_apart(y,max(uint16(x)-1,1)) = 0;
            mask_line_apart(y,uint16(x))=0;
            mask_line_apart(y,min(uint16(x)+1,640))=0;
            % Only change the mask line and nearby +-1 to 0, all other area 1.
        end
    end
    
    fly_body = fly_body_ori.*mask_line_apart;
    rp_body = regionprops(logical(fly_body),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    
    if length(rp_body)>2
        fly_body = bwareafilt(logical(fly_body),2);
        rp_body = regionprops(logical(fly_body),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    end
    
    if length(rp_body)==2 && min([rp_body.Area])> 0.6*min(initial_body_area)
        % body seperation succeed
        % Get a middle region, used later to separate the flies_with_wings
        middle_region = fly_body_ori.*(~fly_body); 
    else
        fly_body = fly_body_ori;
        fprintf('fly_apart: body cannot be separted in frame %d.\n',frame);
        fly_apart_error = 1;
        %keyboard
        return
    end
    
elseif length(rp_body)==2 && length(rp_with_wing) == 1 % body can be seperated but wings cannot
    flies_body_dilate = fly_body;
    rp_body_dilate = regionprops(logical(flies_body_dilate),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    
    while length(rp_body_dilate)==2
        %flies_body_dilate_pre = flies_body_dilate;
        flies_body_dilate = imdilate (flies_body_dilate,se);
        rp_body_dilate = regionprops(logical(flies_body_dilate),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    end
    % regions in flies_body is now bridged. 2 to 1. Perform three more
    % times to make sure the connection is not too small
    
    flies_body_dilate = imdilate (flies_body_dilate,se);
    flies_body_dilate = imdilate (flies_body_dilate,se);
    flies_body_dilate = imdilate (flies_body_dilate,se);
    
    rp_body_dilate = regionprops(logical(flies_body_dilate),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    
    
    % Now erode the flies_body_dilate until it become smaller than the real body
    
    try
        while sum([rp_body_dilate.Area]) > sum([rp_body.Area]) && length(rp_body_dilate)==1
            flies_body_dilate = imerode(flies_body_dilate,se_small);
            rp_body_dilate = regionprops(logical(flies_body_dilate),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
        end
        
    catch
        fprintf('fly_apart: error calculating body_dilate area in frame %d\n',frame)
        %keyboard
    end

    if length(rp_body_dilate)==1
        middle_region = flies_body_dilate.*(~fly_body);
        try
            middle_region = bwareafilt(logical(middle_region),1);
        catch
            fprintf('fly_apart: middle_region area error in frame %d\n',frame)
            %keyboard
        end
    else
        %Meaning that the erosion method is not working in this case, use a middle_region to erase flies_with_wings later.
        middle_region = ones(480,640);
    end
    %flies_with_wings_debug = flies_with_wings;
else
    fprintf('fly_apart: unknown error in frame %d.\n', frame);
    fly_apart_error = 9;
    %keyboard
    return
end


while length(rp_with_wing) == 1 && ~isempty(fly_with_wing)
    fly_with_wing = fly_with_wing.*(~middle_region);
    fly_with_wing = bwareaopen(fly_with_wing,200);
    rp_with_wing = regionprops(logical(fly_with_wing),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    middle_region = imdilate (middle_region,se_small);
end


if length(rp_with_wing) ==2
    return
elseif length(rp_with_wing) > 2
    fly_with_wing = bwareafilt(logical(fly_with_wing),2);
    rp_with_wing = regionprops(logical(fly_with_wing),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    return
elseif length(rp_with_wing) < 2
    % Previous method is not working, try a new approach
    % 1. Connect the two body centroid with a line
    % 2. imdilate the line, but limit it with the body
    
    fly_with_wing = fly_with_wing_ori;
    rp_with_wing = regionprops(logical(fly_with_wing),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');

    
    
    x1y1 = [rp_body(1).Centroid];
    x2y2 = [rp_body(2).Centroid];
    k = (x2y2(2)-x1y1(2))/(x2y2(1)-x1y1(1));
    % y = kx + b
    b = x1y1(2)-k*x1y1(1);
    
    
    % A line that connects the body centroids.
    connection_line = zeros(480,640);
    upper_limit_y = uint16(max(x2y2(2),x1y1(2)));
    lower_limit_y = uint16(min(x2y2(2),x1y1(2)));
    for x = min(x2y2(1),x1y1(1)):0.05:max(x2y2(1),x1y1(1))
            upper_y = max(uint16(k*x+b),uint16(k*(x+1)+b));
            lower_y = min(uint16(k*x+b),uint16(k*(x+1)+b));
            upper_y = uint16(upper_y + rp_body(1).MinorAxisLength/1.5);
            lower_y = uint16(lower_y - rp_body(1).MinorAxisLength/1.5);
                                   
        for y = min(max(lower_y,lower_limit_y),upper_limit_y):min(max(upper_y,lower_limit_y),upper_limit_y)
            % The max() limits the y >= 1.
            % The min() limits the y <= 480
            % So y is always within the range of the width of the video
            % framej
            connection_line(y,uint16(x))=1;
            % Only change the mask line to 0, all other area 1.
        end
    end
    
%     imshow(connection_line|flies_body);
    
    %Get middle region
    middle_region = connection_line.*(~fly_body);
    
    flies_body_dilate = fly_body;
    rp_body_dilate = regionprops(logical(flies_body_dilate),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    
    
    while length(rp_with_wing) == 1 && ~isempty(fly_with_wing)
        fly_with_wing = fly_with_wing.*(~middle_region);
        fly_with_wing = bwareaopen(fly_with_wing,200);
        rp_with_wing = regionprops(logical(fly_with_wing),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
        middle_region = imdilate (middle_region,se_small);
        
        if length(rp_body_dilate) == 2
            middle_region = middle_region.*(~flies_body_dilate);
            flies_body_dilate = flies_body_dilate.*(~middle_region);
            flies_body_dilate = imdilate (flies_body_dilate,se_small);
            rp_body_dilate = regionprops(logical(flies_body_dilate),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
        end
   

    end
end

if length(rp_with_wing) == 3 %In very rare cases, the flies_with_wings are separated into 3, let's connect them back into two.
    part_1 = bwareafilt(logical(fly_with_wing),1);
    part_2 = bwareafilt(logical(fly_with_wing),1,'smallest'); %Normally is wing
    part_3 = fly_with_wing .* (~(part_1 | part_2));
    
    part_1_2 = logical(part_1 | part_2);
    part_2_3 = logical(part_2 | part_3);  
    
    if  body_dist_appr(part_1_2) <= body_dist_appr(part_2_3)
        part_3_dilate = imdilate(part_3,se);
        while length(rp_with_wing)==3
            part_2 = imdilate (part_2,se_small);
            part_2 = part_2.*(~part_3_dilate);
            fly_with_wing = (part_1 | part_2 | part_3);
            rp_with_wing = regionprops(logical(fly_with_wing),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
        end       
    elseif body_dist_appr(part_1_2) > body_dist_appr(part_2_3)
        part_1_dilate = imdilate(part_1,se);
        while length(rp_with_wing)==3
            part_2 = imdilate (part_2,se_small);
            part_2 = part_2.*(~part_1_dilate);
            fly_with_wing = (part_1 | part_2 | part_3);
            rp_with_wing = regionprops(logical(fly_with_wing),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
        end

        
        
    end
end
    
    

if length(rp_with_wing) ~= 2 || length(rp_body) ~= 2
    fprintf('fly_apart: final check, this shouldnt be excuted in frame %d.\n',frame);
    fly_apart_error = 5;
    %keyboard;
end


end




    
    




