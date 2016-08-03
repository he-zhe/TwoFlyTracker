allfiles_ori = uigetfile('*.mp4','MultiSelect','on');

if ~ischar(allfiles_ori)
    allfiles = cell2struct(allfiles_ori,'name');
else
    allfiles = struct;
    allfiles(1).name = allfiles_ori;
end

SPEED = 0.029;
DIST = 0.66;
AREA = 0.85;

yes_n = 1;
no_n = 1;

for fi = 1:length(allfiles)
    load(strcat(allfiles(fi).name(1:end-4),'_crrcted','.','mat'));
    init_body_area = mean(area (:,StartTracking));
    movie = VideoReader(moviefile);
    agg_s = zeros(1, length(min_body_dist_s));
    for frame = StartTracking:StopTracking
        if frame >5
            speed_1 = sqrt((posx(1,frame)-posx(1,frame-5))^2 + (posy(1,frame)-posy(1,frame-5))^2)/ROIs(3);
            speed_2 = sqrt((posx(2,frame)-posx(2,frame-5))^2 + (posy(2,frame)-posy(2,frame-5))^2)/ROIs(3);
        else
            speed_1 = 0;
            speed_2 = 0;
        end
        min_speed = min(speed_1,speed_2);
        dist = min_body_dist_s(1,frame)/ROIs(3);
        wing_area = max(sum(distant_wing_area_s(1:2, frame)), sum(distant_wing_area_s(3:4, frame)))/init_body_area;
        
        if min_speed > SPEED && dist < DIST && wing_area > AREA
            agg_s(1,frame) = 1;
%             ff = read(movie, frame);
%             imshow(ff);
%             keyboard;
        end
    end
    save(strcat(allfiles(fi).name(1:end-4),'_crrcted','.','mat'), 'agg_s','-append');
end