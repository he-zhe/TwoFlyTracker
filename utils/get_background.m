function background = get_background(annotation_file, movie_file, channel)
% This function takes movie file and annotation file(with ROI) and generate
% a background.

% The ideas is that background is brighter than flies(higher value in RGB).
% So pick the image every 15 frames and get max value in each pixel. So we
% generate the background.

movie = VideoReader(movie_file);
load(annotation_file);

% build logical array of ROIs
ff = read(movie,StartTracking);
ff = ff(:,:,channel);
mask = ROI2mask(ff,ROIs);
first_ff = read(movie,StartTracking);
first_ff = first_ff(:,:,channel);
background = first_ff.*mask;
%     i=0;
%     a= zeros(1,1000);

%     while i < 11
%         frame = randi([StartTracking,StopTracking]);
%         rand_ff = read(movie,frame);
%         rand_ff = rand_ff(:,:,channel);
%         rand_ff = rand_ff.*mask;
%         background = max(background, rand_ff);
%         % disp('While loop')
%         i = i +1;
%         a(i) = sum(sum(background));
%     end
%
%
%     while a(i) - a(i-10)> 20
%         frame = randi([StartTracking,StopTracking]);
%         rand_ff = read(movie,frame);
%         rand_ff = rand_ff(:,:,channel);
%         rand_ff = rand_ff.*mask;
%         background = max(background, rand_ff);
%         %disp('While loop')
%         i = i +1;
%         a(i) = sum(sum(background));
%     end

for frame = StartTracking:uint32((StopTracking-StartTracking)/15):StopTracking %Sample the video every 15 frames.
    ff = read(movie,frame);
    ff = ff(:,:,channel);
    ff = ff.*mask;
    background = max(background, ff); %The background is much brighter than flies.
%     disp(frame);
%     imshow(background);
end

if min(min(background))<50 % If some dark spots still exists, do it again.
    for frame = (StartTracking+200):uint32((StopTracking-StartTracking)/15):StopTracking
        ff = read(movie,frame);
        ff = ff(:,:,channel);
        ff = ff.*mask;
        background = max(background, ff);
%         disp(frame);
%         imshow(background);
    end
end
    
    
    disp('get_background finished')
    
    
end
