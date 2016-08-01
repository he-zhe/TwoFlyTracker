function [posx,posy,orientation,area,MajorAxis,MinorAxis,WE,collisions,min_body_dist_s, fly_apart_error_s,distant_wing_area_s] = assign_flies(fly_apart_error,fly_apart_error_s, fly_body, fly_with_wings,frame,StartTracking,posx,posy,orientation,area,MajorAxis,MinorAxis, WE, WE_is, collisions, collision,min_body_dist_s,min_body_dist,distant_wing_area, distant_wing_area_s)
%ASSIGN_FLIES Summary of this function goes here
%   Detailed explanation goes here

%Record fly_apart_error into a 1xnframes matrix
fly_apart_error_s(1,frame) = fly_apart_error;
jump = 40;

rp_with_wings = regionprops(logical(fly_with_wings),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
rp_body = regionprops(logical(fly_body),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');

if frame >1
    fly_apart_error_pre = fly_apart_error_s(1,frame-1);
else
    fly_apart_error_pre = 0;
end

    function assign_normal
        posx(1,frame) = rp_body(1).Centroid(1);
        posy(1,frame) = rp_body(1).Centroid(2);
        orientation(1,frame) = -rp_body(1).Orientation;
        area(1,frame) = rp_body(1).Area;
        MajorAxis(1,frame) = rp_body(1).MajorAxisLength;
        MinorAxis(1,frame) = rp_body(1).MinorAxisLength;
        WE(1,frame) = WE_is(1);
        distant_wing_area_s(1, frame) = distant_wing_area(1);
        distant_wing_area_s(2, frame) = distant_wing_area(2);
        
        posx(2,frame) = rp_body(2).Centroid(1);
        posy(2,frame) = rp_body(2).Centroid(2);
        orientation(2,frame) = -rp_body(2).Orientation;
        area(2,frame) = rp_body(2).Area;
        MajorAxis(2,frame) = rp_body(2).MajorAxisLength;
        MinorAxis(2,frame) = rp_body(2).MinorAxisLength;
        WE(2,frame) = WE_is(2);
        distant_wing_area_s(3, frame) = distant_wing_area(3);
        distant_wing_area_s(4, frame) = distant_wing_area(4);
        
        collisions(frame) = collision;
        min_body_dist_s(frame) = min_body_dist;
    end

    function assign_inverse
        posx(1,frame) = rp_body(2).Centroid(1);
        posy(1,frame) = rp_body(2).Centroid(2);
        orientation(1,frame) = -rp_body(2).Orientation;
        area(1,frame) = rp_body(2).Area;
        MajorAxis(1,frame) = rp_body(2).MajorAxisLength;
        MinorAxis(1,frame) = rp_body(2).MinorAxisLength;
        WE(1,frame) = WE_is(2);
        distant_wing_area_s(1, frame) = distant_wing_area(3);
        distant_wing_area_s(2, frame) = distant_wing_area(4);
        
        posx(2,frame) = rp_body(1).Centroid(1);
        posy(2,frame) = rp_body(1).Centroid(2);
        orientation(2,frame) = -rp_body(1).Orientation;
        area(2,frame) = rp_body(1).Area;
        MajorAxis(2,frame) = rp_body(1).MajorAxisLength;
        MinorAxis(2,frame) = rp_body(1).MinorAxisLength;
        WE(2,frame) = WE_is(1);
        distant_wing_area_s(3, frame) = distant_wing_area(1);
        distant_wing_area_s(4, frame) = distant_wing_area(2);
        
        collisions(frame) = collision;
        min_body_dist_s(frame) = min_body_dist;
    end

% To troubleshooting specific frame
% if frame == 7975
%     disp('check the fly_apart_error here')
%     keyboard
% end

% fly_apart_error
% 0: No error
% 1: Missing
% Other assign to previous frame.
if fly_apart_error>1
    %disp('fly_apart_error');
    posx(1,frame) = posx(1,frame-1);
    posy(1,frame) = posy(1,frame-1);
    orientation(1,frame) = orientation(1,frame-1);
    area(1,frame) = area(1,frame-1);
    MajorAxis(1,frame) = MajorAxis(1,frame-1);
    MinorAxis(1,frame) = MinorAxis(1,frame-1);
    WE(1,frame) = WE_is(1);
    distant_wing_area_s(1, frame) = distant_wing_area(1);
    distant_wing_area_s(2, frame) = distant_wing_area(2);
    
    posx(2,frame) = posx(2,frame-1);
    posy(2,frame) = posy(2,frame-1);
    orientation(2,frame) = orientation(2,frame-1);
    area(2,frame) = area(2,frame-1);
    MajorAxis(2,frame) = MajorAxis(2,frame-1);
    MinorAxis(2,frame) = MinorAxis(2,frame-1);
    WE(2,frame) = WE_is(2);
    distant_wing_area_s(3, frame) = distant_wing_area(3);
    distant_wing_area_s(4, frame) = distant_wing_area(4);
    
    collisions(frame) = collisions(frame-1);
    min_body_dist_s(frame) = min_body_dist_s(frame-1);
    fly_apart_error_s(1,frame) = fly_apart_error_pre;
    
    return
end

% If this is the first frame, assign
if frame == StartTracking
    % special case, first frame. assume everything OK.
    assign_normal
%     for i = 1:2  %for loop through flies
%         posx(i,StartTracking) = rp_body(i).Centroid(1);
%         posy(i,StartTracking) = rp_body(i).Centroid(2);
%         orientation(i,StartTracking) = -rp_body(i).Orientation;
%         area(i,StartTracking) = rp_body(i).Area;
%         MajorAxis(i,StartTracking) = rp_body(i).MajorAxisLength;
%         MinorAxis(i,StartTracking) = rp_body(i).MinorAxisLength;
%         WE(i,StartTracking) = WE_is(i);
%     end
%     distant_wing_area_s(1, frame) = distant_wing_area(1);
%     distant_wing_area_s(2, frame) = distant_wing_area(2);
%     distant_wing_area_s(3, frame) = distant_wing_area(3);
%     distant_wing_area_s(4, frame) = distant_wing_area(4);
%     collisions(StartTracking) = collision;
%     min_body_dist_s(StartTracking) = min_body_dist;
    return
end



if fly_apart_error ==1 && fly_apart_error_pre ~= 1 %One fly missing in this frame, but not previous frame.
    %Get positions from previous frame
    pre_x_1 = posx(1,frame-1);
    pre_y_1 = posy(1,frame-1);
    pre_x_2 = posx(2,frame-1);
    pre_y_2 = posy(2,frame-1);
    
    %Get positions from current frame,usually only one body region should
    %be found
    current_x = rp_body(1).Centroid(1);
    current_y = rp_body(1).Centroid(2);
    
    %Prepare pos to calculate distance
    pos_current_pre1 = [current_x,current_y; pre_x_1,pre_y_1];
    pos_current_pre2 = [current_x,current_y; pre_x_2,pre_y_2];
    
    %Calculate the distance between current objct and previous two objects,
    %so that we can assign the currenct object to the closer one in
    %previous frame.
    distance_current_pre1 = pdist(pos_current_pre1,'euclidean');
    distance_current_pre2 = pdist(pos_current_pre2,'euclidean');
    
    if distance_current_pre1 <= distance_current_pre2 %fly_2 is missing, assign current to 1
        posx(1,frame) = rp_body.Centroid(1);
        posy(1,frame) = rp_body.Centroid(2);
        orientation(1,frame) = -rp_body.Orientation;
        area(1,frame) = rp_body.Area;
        MajorAxis(1,frame) = rp_body.MajorAxisLength;
        MinorAxis(1,frame) = rp_body.MinorAxisLength;
    elseif distance_current_pre1 >= distance_current_pre2 %fly_1 is missing, assign current to 2
        posx(2,frame) = rp_body.Centroid(1);
        posy(2,frame) = rp_body.Centroid(2);
        orientation(2,frame) = -rp_body.Orientation;
        area(2,frame) = rp_body.Area;
        MajorAxis(2,frame) = rp_body.MajorAxisLength;
        MinorAxis(2,frame) = rp_body.MinorAxisLength;
    end
    
elseif fly_apart_error ==1  && fly_apart_error_pre ==1 %One fly missing in this frame and previous frame.
    if isnan(posx(2,frame-1)) %fly_2 is missing in previous frame, assign current to 1
        posx(1,frame) = rp_body.Centroid(1);
        posy(1,frame) = rp_body.Centroid(2);
        orientation(1,frame) = -rp_body.Orientation;
        area(1,frame) = rp_body.Area;
        MajorAxis(1,frame) = rp_body.MajorAxisLength;
        MinorAxis(1,frame) = rp_body.MinorAxisLength;
    elseif isnan(posx(1,frame-1)) %fly_1 is missing in previous frame, assign current to 2
        posx(2,frame) = rp_body.Centroid(1);
        posy(2,frame) = rp_body.Centroid(2);
        orientation(2,frame) = -rp_body.Orientation;
        area(2,frame) = rp_body.Area;
        MajorAxis(2,frame) = rp_body.MajorAxisLength;
        MinorAxis(2,frame) = rp_body.MinorAxisLength;
    end
    
elseif fly_apart_error == 0 && fly_apart_error_pre ==1 %No fly missing in this frame, but one missing in previous frame.
    if isnan(posx(2,frame-1)) %fly_2 is missing in previous frame
        pre_x_1 = posx(1,frame-1);
        pre_y_1 = posy(1,frame-1);
        current_x_1 = rp_body(1).Centroid(1);
        current_y_1 = rp_body(1).Centroid(2);
        current_x_2 = rp_body(2).Centroid(1);
        current_y_2 = rp_body(2).Centroid(2);
        
        pos_current1_1 = [current_x_1,current_y_1; pre_x_1,pre_y_1];
        pos_current2_1 = [current_x_2,current_y_2; pre_x_1,pre_y_1];
        
        distance_current1_pre1 = pdist(pos_current1_1,'euclidean');
        distance_current2_pre1 = pdist(pos_current2_1,'euclidean');
        
        if distance_current1_pre1 <= distance_current2_pre1 %current 1 is closer to pre_1, assign 1 to 1, 2 to 2
            assign_normal
%             for i = 1:2  %for loop through flies
%                 posx(i,frame) = rp_body(i).Centroid(1);
%                 posy(i,frame) = rp_body(i).Centroid(2);
%                 orientation(i,frame) = -rp_body(i).Orientation;
%                 area(i,frame) = rp_body(i).Area;
%                 MajorAxis(i,frame) = rp_body(i).MajorAxisLength;
%                 MinorAxis(i,frame) = rp_body(i).MinorAxisLength;
%                 WE(i,frame) = WE_is(i);
%             end
%             distant_wing_area_s(1, frame) = distant_wing_area(1);
%             distant_wing_area_s(2, frame) = distant_wing_area(2);
%             distant_wing_area_s(3, frame) = distant_wing_area(3);
%             distant_wing_area_s(4, frame) = distant_wing_area(4);
        elseif distance_current1_pre1 >= distance_current2_pre1
            assign_inverse
%             posx(1,frame) = rp_body(2).Centroid(1);
%             posy(1,frame) = rp_body(2).Centroid(2);
%             orientation(1,frame) = -rp_body(2).Orientation;
%             area(1,frame) = rp_body(2).Area;
%             MajorAxis(1,frame) = rp_body(2).MajorAxisLength;
%             MinorAxis(1,frame) = rp_body(2).MinorAxisLength;
%             WE(1,frame) = WE_is(2);
%             
%             posx(2,frame) = rp_body(1).Centroid(1);
%             posy(2,frame) = rp_body(1).Centroid(2);
%             orientation(2,frame) = -rp_body(1).Orientation;
%             area(2,frame) = rp_body(1).Area;
%             MajorAxis(2,frame) = rp_body(1).MajorAxisLength;
%             MinorAxis(2,frame) = rp_body(1).MinorAxisLength;
%             WE(2,frame) = WE_is(1);
%             distant_wing_area_s(1, frame) = distant_wing_area(3);
%             distant_wing_area_s(2, frame) = distant_wing_area(4);
%             distant_wing_area_s(3, frame) = distant_wing_area(1);
%             distant_wing_area_s(4, frame) = distant_wing_area(2);
%             
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
        end
        
        
    elseif isnan(posx(1,frame-1)) %fly_1 is missing in previous frame
        pre_x_2 = posx(2,frame-1);
        pre_y_2 = posy(2,frame-1);
        current_x_1 = rp_body(1).Centroid(1);
        current_y_1 = rp_body(1).Centroid(2);
        current_x_2 = rp_body(2).Centroid(1);
        current_y_2 = rp_body(2).Centroid(2);
        
        pos_current1_2 = [current_x_1,current_y_1; pre_x_2,pre_y_2];
        pos_current2_2 = [current_x_2,current_y_2; pre_x_2,pre_y_2];
        
        distance_current1_pre2 = pdist(pos_current1_2,'euclidean');
        distance_current2_pre2 = pdist(pos_current2_2,'euclidean');
        
        if distance_current1_pre2 >= distance_current2_pre2 %current 2 is closer to pre_2, assign 1 to 1
            assign_normal
%             for i = 1:2  %for loop through flies
%                 posx(i,frame) = rp_body(i).Centroid(1);
%                 posy(i,frame) = rp_body(i).Centroid(2);
%                 orientation(i,frame) = -rp_body(i).Orientation;
%                 area(i,frame) = rp_body(i).Area;
%                 MajorAxis(i,frame) = rp_body(i).MajorAxisLength;
%                 MinorAxis(i,frame) = rp_body(i).MinorAxisLength;
%                 WE(i,frame) = WE_is(i);
%                 
%             end
%             distant_wing_area_s(1, frame) = distant_wing_area(1);
%             distant_wing_area_s(2, frame) = distant_wing_area(2);
%             distant_wing_area_s(3, frame) = distant_wing_area(3);
%             distant_wing_area_s(4, frame) = distant_wing_area(4);
        elseif distance_current1_pre2 < distance_current2_pre2
            assign_inverse
%             posx(1,frame) = rp_body(2).Centroid(1);
%             posy(1,frame) = rp_body(2).Centroid(2);
%             orientation(1,frame) = -rp_body(2).Orientation;
%             area(1,frame) = rp_body(2).Area;
%             MajorAxis(1,frame) = rp_body(2).MajorAxisLength;
%             MinorAxis(1,frame) = rp_body(2).MinorAxisLength;
%             WE(1,frame) = WE_is(2);
%             distant_wing_area_s(1, frame) = distant_wing_area(3);
%             distant_wing_area_s(2, frame) = distant_wing_area(4);
%             
%             posx(2,frame) = rp_body(1).Centroid(1);
%             posy(2,frame) = rp_body(1).Centroid(2);
%             orientation(2,frame) = -rp_body(1).Orientation;
%             area(2,frame) = rp_body(1).Area;
%             MajorAxis(2,frame) = rp_body(1).MajorAxisLength;
%             MinorAxis(2,frame) = rp_body(1).MinorAxisLength;
%             WE(2,frame) = WE_is(1);
% 
%             distant_wing_area_s(3, frame) = distant_wing_area(1);
%             distant_wing_area_s(4, frame) = distant_wing_area(2);
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
        else
            disp('unexpected in one fly missing in this frame (%d) and previous frame(%d).', frame,(frame-1));
            beep
            %keyboard
        end
    end
    
    
    
elseif fly_apart_error == 0 && fly_apart_error_pre ==0 %No fly missing in this frame or previous frame.
    
    pre_x_1 = posx(1,frame-1);
    pre_y_1 = posy(1,frame-1);
    pre_x_2 = posx(2,frame-1);
    pre_y_2 = posy(2,frame-1);
    current_x_1 = rp_body(1).Centroid(1);
    current_y_1 = rp_body(1).Centroid(2);
    current_x_2 = rp_body(2).Centroid(1);
    current_y_2 = rp_body(2).Centroid(2);
    
    pos_a_1 = [current_x_1,current_y_1; pre_x_1,pre_y_1];
    pos_b_1 = [current_x_2,current_y_2; pre_x_1,pre_y_1];
    pos_a_2 = [current_x_1,current_y_1; pre_x_2,pre_y_2];
    pos_b_2 = [current_x_2,current_y_2; pre_x_2,pre_y_2];
    
    
    distance_a_1 = pdist(pos_a_1,'euclidean');
    distance_b_1 = pdist(pos_b_1,'euclidean');
    distance_a_2 = pdist(pos_a_2,'euclidean');
    distance_b_2 = pdist(pos_b_2,'euclidean');
    
    %if no jump
    if (distance_a_1<=jump || distance_a_2<=jump) && (distance_b_1<=jump || distance_b_2<=jump)
        if (distance_a_1 + distance_b_2) <= (distance_b_1 + distance_a_2)
            assign_normal
%             for i = 1:2  %for loop through flies
%                 posx(i,frame) = rp_body(i).Centroid(1);
%                 posy(i,frame) = rp_body(i).Centroid(2);
%                 orientation(i,frame) = -rp_body(i).Orientation;
%                 area(i,frame) = rp_body(i).Area;
%                 MajorAxis(i,frame) = rp_body(i).MajorAxisLength;
%                 MinorAxis(i,frame) = rp_body(i).MinorAxisLength;
%                 WE(i,frame) = WE_is(i);
%             end
%             distant_wing_area_s(1, frame) = distant_wing_area(1);
%             distant_wing_area_s(2, frame) = distant_wing_area(2);
%             distant_wing_area_s(3, frame) = distant_wing_area(3);
%             distant_wing_area_s(4, frame) = distant_wing_area(4);
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
%             
        elseif (distance_a_2 + distance_b_1) <= (distance_a_1 + distance_b_2)
            assign_inverse
%             posx(1,frame) = rp_body(2).Centroid(1);
%             posy(1,frame) = rp_body(2).Centroid(2);
%             orientation(1,frame) = -rp_body(2).Orientation;
%             area(1,frame) = rp_body(2).Area;
%             MajorAxis(1,frame) = rp_body(2).MajorAxisLength;
%             MinorAxis(1,frame) = rp_body(2).MinorAxisLength;
%             WE(1,frame) = WE_is(2);
%             
%             distant_wing_area_s(1, frame) = distant_wing_area(3);
%             distant_wing_area_s(2, frame) = distant_wing_area(4);
% 
%             
%             posx(2,frame) = rp_body(1).Centroid(1);
%             posy(2,frame) = rp_body(1).Centroid(2);
%             orientation(2,frame) = -rp_body(1).Orientation;
%             area(2,frame) = rp_body(1).Area;
%             MajorAxis(2,frame) = rp_body(1).MajorAxisLength;
%             MinorAxis(2,frame) = rp_body(1).MinorAxisLength;
%             WE(2,frame) = WE_is(1);
%             distant_wing_area_s(3, frame) = distant_wing_area(1);
%             distant_wing_area_s(4, frame) = distant_wing_area(2);
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
        end
        
        
        % fly_1 jump, fly_2 not
    elseif (distance_a_1>=jump && distance_a_2>=jump) && (distance_b_1<=jump || distance_b_2<=jump)
        if distance_b_2 <= distance_b_1
            assign_normal
%             for i = 1:2  %for loop through flies
%                 posx(i,frame) = rp_body(i).Centroid(1);
%                 posy(i,frame) = rp_body(i).Centroid(2);
%                 orientation(i,frame) = -rp_body(i).Orientation;
%                 area(i,frame) = rp_body(i).Area;
%                 MajorAxis(i,frame) = rp_body(i).MajorAxisLength;
%                 MinorAxis(i,frame) = rp_body(i).MinorAxisLength;
%                 WE(i,frame) = WE_is(i);
%             end
%             distant_wing_area_s(1, frame) = distant_wing_area(1);
%             distant_wing_area_s(2, frame) = distant_wing_area(2);
%             distant_wing_area_s(3, frame) = distant_wing_area(3);
%             distant_wing_area_s(4, frame) = distant_wing_area(4);
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
            
        elseif distance_b_1 <= distance_b_2
            assign_inverse
%             posx(1,frame) = rp_body(2).Centroid(1);
%             posy(1,frame) = rp_body(2).Centroid(2);
%             orientation(1,frame) = -rp_body(2).Orientation;
%             area(1,frame) = rp_body(2).Area;
%             MajorAxis(1,frame) = rp_body(2).MajorAxisLength;
%             MinorAxis(1,frame) = rp_body(2).MinorAxisLength;
%             WE(1,frame) = WE_is(2);
%             distant_wing_area_s(1, frame) = distant_wing_area(3);
%             distant_wing_area_s(2, frame) = distant_wing_area(4);
%             
%             posx(2,frame) = rp_body(1).Centroid(1);
%             posy(2,frame) = rp_body(1).Centroid(2);
%             orientation(2,frame) = -rp_body(1).Orientation;
%             area(2,frame) = rp_body(1).Area;
%             MajorAxis(2,frame) = rp_body(1).MajorAxisLength;
%             MinorAxis(2,frame) = rp_body(1).MinorAxisLength;
%             WE(2,frame) = WE_is(1);
%             distant_wing_area_s(3, frame) = distant_wing_area(1);
%             distant_wing_area_s(4, frame) = distant_wing_area(2);
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
        end
        
        % fly_2 jump, fly_1 not
    elseif (distance_a_1<=jump || distance_a_2<=jump) && (distance_b_1>=jump && distance_b_2>=jump)
        if distance_a_1 <= distance_a_2
            assign_normal
%             for i = 1:2  %for loop through flies
%                 posx(i,frame) = rp_body(i).Centroid(1);
%                 posy(i,frame) = rp_body(i).Centroid(2);
%                 orientation(i,frame) = -rp_body(i).Orientation;
%                 area(i,frame) = rp_body(i).Area;
%                 MajorAxis(i,frame) = rp_body(i).MajorAxisLength;
%                 MinorAxis(i,frame) = rp_body(i).MinorAxisLength;
%                 WE(i,frame) = WE_is(i);
%             end
%             distant_wing_area_s(1, frame) = distant_wing_area(1);
%             distant_wing_area_s(2, frame) = distant_wing_area(2);
%             distant_wing_area_s(3, frame) = distant_wing_area(3);
%             distant_wing_area_s(4, frame) = distant_wing_area(4);
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
            
        elseif distance_a_2 <= distance_a_1
            assign_inverse
%             posx(1,frame) = rp_body(2).Centroid(1);
%             posy(1,frame) = rp_body(2).Centroid(2);
%             orientation(1,frame) = -rp_body(2).Orientation;
%             area(1,frame) = rp_body(2).Area;
%             MajorAxis(1,frame) = rp_body(2).MajorAxisLength;
%             MinorAxis(1,frame) = rp_body(2).MinorAxisLength;
%             WE(1,frame) = WE_is(2);
%             
%             posx(2,frame) = rp_body(1).Centroid(1);
%             posy(2,frame) = rp_body(1).Centroid(2);
%             orientation(2,frame) = -rp_body(1).Orientation;
%             area(2,frame) = rp_body(1).Area;
%             MajorAxis(2,frame) = rp_body(1).MajorAxisLength;
%             MinorAxis(2,frame) = rp_body(1).MinorAxisLength;
%             WE(2,frame) = WE_is(1);
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
        end
    elseif (distance_a_1>=jump && distance_a_2>=jump) && (distance_b_1>=jump && distance_b_2>=jump)
        fprintf('Both flies jumped in frame %d.\n',frame)
        if (distance_a_1 + distance_b_2) <= (distance_b_1 + distance_a_2)
            assign_normal
%             for i = 1:2  %for loop through flies
%                 posx(i,frame) = rp_body(i).Centroid(1);
%                 posy(i,frame) = rp_body(i).Centroid(2);
%                 orientation(i,frame) = -rp_body(i).Orientation;
%                 area(i,frame) = rp_body(i).Area;
%                 MajorAxis(i,frame) = rp_body(i).MajorAxisLength;
%                 MinorAxis(i,frame) = rp_body(i).MinorAxisLength;
%                 WE(i,frame) = WE_is(i);
%             end
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
            
        elseif (distance_a_2 + distance_b_1) <= (distance_a_1 + distance_b_2)
            assign_inverse
%             posx(1,frame) = rp_body(2).Centroid(1);
%             posy(1,frame) = rp_body(2).Centroid(2);
%             orientation(1,frame) = -rp_body(2).Orientation;
%             area(1,frame) = rp_body(2).Area;
%             MajorAxis(1,frame) = rp_body(2).MajorAxisLength;
%             MinorAxis(1,frame) = rp_body(2).MinorAxisLength;
%             WE(1,frame) = WE_is(2);
%             
%             posx(2,frame) = rp_body(1).Centroid(1);
%             posy(2,frame) = rp_body(1).Centroid(2);
%             orientation(2,frame) = -rp_body(1).Orientation;
%             area(2,frame) = rp_body(1).Area;
%             MajorAxis(2,frame) = rp_body(1).MajorAxisLength;
%             MinorAxis(2,frame) = rp_body(1).MinorAxisLength;
%             WE(2,frame) = WE_is(1);
%             collisions(frame) = collision;
%             min_body_dist_s(frame) = min_body_dist;
        end
    end
    
    
else
    disp('First frame or unknown error')
    %beep
    %keyboard
end

if isnan(posx(1,frame)) && isnan(posx(2,frame))
    posx(1,frame) = posx(1,frame-1);
    posy(1,frame) = posy(1,frame-1);
    orientation(1,frame) = orientation(1,frame-1);
    area(1,frame) = area(1,frame-1);
    MajorAxis(1,frame) = MajorAxis(1,frame-1);
    MinorAxis(1,frame) = MinorAxis(1,frame-1);
    WE(1,frame) = WE_is(1);
    
    posx(2,frame) = posx(2,frame-1);
    posy(2,frame) = posy(2,frame-1);
    orientation(2,frame) = orientation(2,frame-1);
    area(2,frame) = area(2,frame-1);
    MajorAxis(2,frame) = MajorAxis(2,frame-1);
    MinorAxis(2,frame) = MinorAxis(2,frame-1);
    WE(2,frame) = WE_is(2);
    
    collisions(frame) = collisions(frame-1);
    min_body_dist_s(frame) = min_body_dist_s(frame-1);
    
    
    disp('In frame'),disp(frame),disp('both cordination is lost.')
    %beep
    %keyboard
    
end

%When one fly is missing in pre, and in current there is a fly apart error,
%change the current fly apart error to 1, so that the next frame we know
%one fly is missing.
if fly_apart_error > 1 && fly_apart_error_pre ==1
    fly_apart_error_s(1,frame) =1;
end

end