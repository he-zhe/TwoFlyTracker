
allfiles_ori = uigetfile('*crrcted.mat','MultiSelect','on');

if ~ischar(allfiles_ori)
    allfiles = cell2struct(allfiles_ori,'name');
else
    allfiles = struct;
    allfiles(1).name = allfiles_ori;
end


for fi =1:length(allfiles)
    
    
    annotation_file = allfiles(fi).name;
    load(annotation_file);
    fprintf('%s loaded\n', annotation_file);
    movie = VideoReader(moviefile);
    
    nframes = get(movie,'NumberOfFrames');
 
    
    outputVideo = VideoWriter(strcat(allfiles(fi).name,'.avi'));
    orivideo = VideoWriter(strcat(allfiles(fi).name,'_ori.avi'));
    outputVideo.FrameRate = movie.FrameRate;
    orivideo.FrameRate = movie.FrameRate;
    open(outputVideo);
    open(orivideo);
    
    for frame = StartTracking:StopTracking
        tic
        J = show_fly_info_agg( movie,frame,posx,posy,agg_s,min_body_dist_s,speed_s,collisions,ROIs);
        ff_ori = read(movie,frame);
        writeVideo(outputVideo,J);
        writeVideo(orivideo,ff_ori);
        
        fprintf('Frame: %d\n',frame);
        
        if rem(frame,1000)==0
            t = toc;
            fps = 1/t;
            fprintf('frame:%d.  fps: %f.\n',frame,fps);
        end
        
    end
    
    
    
    close(outputVideo);
    close(orivideo)
    clearvars -except allfiles fi;
end

send_email('Movie Finished','')
