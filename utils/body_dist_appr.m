function [ min_body_dist_appr ] = body_dist_appr( flies_body )
%BODY_DIST_APPR Summary of this function goes here
%   Detailed explanation goes here

    rp_body = regionprops(logical(flies_body),'Orientation','Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','BoundingBox','Image');
    
    if length(rp_body) ~= 2
        min_body_dist_appr = -1;
        return
    end
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
        for y = min(max(lower_y,lower_limit_y),upper_limit_y):min(max(upper_y,lower_limit_y),upper_limit_y)
            % The max() limits the y >= 1.
            % The min() limits the y <= 480
            % So y is always within the range of the width of the video
            % framej
            connection_line(y,uint16(x))=1;
            % Only change the mask line to 0, all other area 1.
        end
    end
    
    distance_line = connection_line.*(~flies_body);
    %imshow(distance_line);
    rp_distance_line = regionprops(distance_line, 'MajorAxisLength');
    if ~isempty(rp_distance_line)
        min_body_dist_appr = max(rp_distance_line.MajorAxisLength);
    else
        min_body_dist_appr = 0;
    end
    

end

