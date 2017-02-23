function ff = show_fly_info_WE( movie,frame,posx,posy,WE,min_body_dist_s,speed_s,collisions,ROIs)
% This function returns a image that has the following annotation:
% position & gender: marked by "M" & "F"
% speed: mm/sec
% distance: mm
% collision & wing-extension status
% frame number

%% this norm factor convert the unit speed and distance: pixel --> mm

fps = get(movie, 'FrameRate');
norm_factor = 7.78/ROIs(3);

%% M & F, positions

ff_ori = read(movie,frame);
fly_1_x = max(0,posx(1,frame));
fly_2_x = max(0,posx(2,frame));
fly_1_y = max(0,posy(1,frame));
fly_2_y = max(0,posy(2,frame));

fly_ID_insert = vision.TextInserter('%s', 'LocationSource', 'Input port', 'Color',  [236, 240, 241], 'FontSize', 20);
strings_fly_ID = uint8(['M' 0 'F']);
ff = step(fly_ID_insert, ff_ori, strings_fly_ID, uint32([fly_1_x-10 fly_1_y-10;fly_2_x-10 fly_2_y-10]));

%% Speed

fly_speed_insert = vision.TextInserter('%s', 'LocationSource', 'Input port', 'Color',  [231, 76, 60], 'FontSize', 24);
speeed_1 = speed_s(1,frame)*norm_factor*fps;
speeed_2 = speed_s(2,frame)*norm_factor*fps;

speed_1_char = num2str(speeed_1,'%.2f');
speed_2_char = num2str(speeed_2,'%.2f');

strings_speed = uint8([speed_1_char 0 speed_2_char]);
ff = step(fly_speed_insert, ff, strings_speed, uint32([fly_1_x fly_1_y+26;fly_2_x fly_2_y+26]));

%% Frame in the left-lower corner

frame_insert = vision.TextInserter('%d', 'LocationSource', 'Input port','Color',  [255, 255, 255], 'FontSize', 24);
%      frame_str = uint8(num2str(frame));
frame_pos = [5 450];
ff = step(frame_insert, ff, uint32(frame), uint32(frame_pos));

%% body distance

if fly_1_x~=0 && fly_2_x~=0 && fly_1_y~=0 && fly_2_y~=0
    min_body_dist_s_insert  = vision.TextInserter('%s', 'LocationSource', 'Input port', 'Color',  [46, 204, 113], 'FontSize', 24);
    strings_min_body_dist_s_insert = uint8(num2str(min_body_dist_s(frame)*norm_factor,'%.1f'));
    ff = step(min_body_dist_s_insert, ff, strings_min_body_dist_s_insert, uint32([0.5*(fly_1_x+fly_2_x) 0.5*(fly_1_y+fly_2_y)]));
    
    line_insert = vision.ShapeInserter('Shape','Lines','BorderColorSource','Input port','LineWidth',3);
    
    line = uint32([fly_1_x,fly_1_y,fly_2_x,fly_2_y]);
    ff = step(line_insert,ff,line,uint8([46, 204, 113]));
end

%% insert a textbox for collision & wing extension

textbox_insert = vision.ShapeInserter('Shape','Rectangles','Fill',true,'FillColor','Custom','CustomFillColor',[236 240 241],'Opacity',0.5);
rectangle = [ROIs(1)-ROIs(3) 1 195 75];
ff = step(textbox_insert,ff,uint8(rectangle));

%% Wing extension

WE_insert = vision.TextInserter('%s', 'LocationSource', 'Input port','Color',  [50, 50, 219], 'FontSize', 24);
WE_pos = [ROIs(1)-ROIs(3)+2 15];

if WE(1,frame)==1 || WE(2,frame) == 1
    strings_WE = uint8('mm Wing Extension');
    ff = step(WE_insert, ff, strings_WE, uint32(WE_pos));
    %     elseif WE(1,frame)==0 && WE(2,frame) == 1
    %         strings_WE = uint8('WE_Fly_2');
    %         ff = step(WE_insert, ff, strings_WE);
    %     elseif WE(1,frame)==1 && WE(2,frame) == 1
    %         strings_WE = uint8('WE_Fly_1 and WE_Fly_2');
    %         ff = step(WE_insert, ff, strings_WE);
end

%% collision

collisions_insert = vision.TextInserter('%s', 'LocationSource', 'Input port', 'Color',  [0, 255, 0], 'FontSize', 24);
collisions_pos = [ROIs(1)-ROIs(3)+2 45];

if collisions(frame)==1
    strings_collisions = uint8('Collision');
    
    ff = step (collisions_insert,ff,strings_collisions,uint32(collisions_pos));
end

%% trail in last 5 frames

%     if all(all(posx(:,frame-5:frame)>0)) && all(all(posy(:,frame-5:frame)>0))
%         pos = zeros(2,12);
%         i=1;
%         for n = 1:2
%             for n_frame = frame-5:frame
%                 pos(n,i) = posx(n,n_frame);
%                 pos(n,i+1) = posy(n,n_frame);
%                 i=i+2;
%             end
%             i=1;
%         end
%
%         line_insert_1 = vision.ShapeInserter('Shape','Lines');
%         line_insert_2 = vision.ShapeInserter('Shape','Lines');
%
%
%         line_insert_1.BorderColor = 'Custom';
%         line_insert_2.BorderColor = 'Custom';
%
%         line_insert_1.LineWidth = 3;
%         line_insert_2.LineWidth = 3;
%
%         line_insert_1.CustomBorderColor = [0 0 255];
%         line_insert_2.CustomBorderColor = [255 0 0];
%
%         ff = step(line_insert_1,ff,uint32(pos(1,:)));
%         ff = step(line_insert_2,ff,uint32(pos(2,:)));
%     end

%  catch
%      disp('Video can not be generated')
%      ff = ff_ori;
%  end

end

