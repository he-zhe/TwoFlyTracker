% -----------Run manual_correction before running this script.-------------

% This script calculates the speed of each fly in each frame. The unit is
% pixel/frame.
% The results will be appended to the *.mat file. 



allfiles_ori = uigetfile('*crrcted.mat','MultiSelect','on');

if ~ischar(allfiles_ori)
    allfiles = cell2struct(allfiles_ori,'name');
else
    allfiles = struct;
    allfiles(1).name = allfiles_ori;
end

for fi =1:length(allfiles)
    
    load (allfiles(fi).name);
    
    %if is_manual_corrected == 1
        movie = VideoReader(moviefile);
        nframes = get(movie,'NumberOfFrames');
        speed_s = NaN(2,nframes);

        for frame = StartTracking+1:StopTracking
            for n = 1:2 %two flies
                if ~isnan(posx(n,frame)) && ~isnan(posy(n,frame)) && ~isnan(posx(n,frame-1)) && ~isnan(posy(n,frame-1))
                    speed_s(n,frame) = pdist([posx(n,frame),posy(n,frame);posx(n,frame-1),posy(n,frame-1)],'euclidean');
                else
                    speed_s(n,frame) = NaN;
                end
            end
        end

        save(allfiles(fi).name,'speed_s','-append')

        fprintf('%s Speed Calculation Finished\n',allfiles(fi).name);
        clearvars -except allfiles fi;
    %else
        %fprintf('%s has not been manually corrected. Speed calculation aborted.\n',allfiles(fi).name);
    %end
end

