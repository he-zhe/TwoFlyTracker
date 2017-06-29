%collision


allfiles_ori = uigetfile('*crrcted.mat','MultiSelect','on');

if ~ischar(allfiles_ori)
    allfiles = cell2struct(allfiles_ori,'name');
else
    allfiles = struct;
    allfiles(1).name = allfiles_ori;
end

result_database={'File','Male_Mean_Speed','Female_Mean_speed','Mean_body_dist','# of Collisions','events of male WE','events of female WE','male number of frames' , 'female number of frames', 'First WE 1', 'First WE 2', 'total time' };

for fi =1:length(allfiles)
    
    disp(allfiles(fi).name),disp('started')
    
    
    load (allfiles(fi).name);
    
    speed_s = posx; %Just for initialization, not for actual number
    movie = VideoReader(moviefile);
    fps = get(movie, 'FrameRate');
    
    
    for frame = StartTracking+1:StopTracking
        for n = 1:2 %t  wo flies
            if ~isnan(posx(n,frame)) && ~isnan(posy(n,frame)) && ~isnan(posx(n,frame-1)) && ~isnan(posy(n,frame-1))
                speed_s(n,frame) = pdist([posx(n,frame),posy(n,frame);posx(n,frame-1),posy(n,frame-1)],'euclidean');
            else
                speed_s(n,frame) = NaN;
            end
        end
    end
    
    % The diameter of the arena is 15.56mmm. Radius 7.78mm.
    % Multiply the results by norm_factor to convert it to mm.
    norm_factor = 7.78/ROIs(3);
    
    % Convert speed from pixel/frame to pixel/sec
    speed_s = speed_s*fps;
    
    
    
    mean_speed_1_summary = nanmean(speed_s(1,:))*norm_factor;
    
    mean_speed_2_summary = nanmean(speed_s(2,:))*norm_factor;
    
    min_body_dist_summary = nanmean(min_body_dist_s)*norm_factor;
    
    
    collisions(isnan(collisions))=0;
    collisions = remove_single_1_0(collisions);
    [collisions_ons,~] = ComputeOnsOffs(collisions);
    collisions_summary = size(collisions_ons);
    collisions_summary = collisions_summary(1);
    
    WE_male = WE(1,:);
    WE_male(isnan(WE(1,:))) = 0;
    WE_s_1 = remove_n_consecutive(WE_male, 0);
    WE_frames_1 = sum (WE_s_1);
    [WE_s_1_ons,~] = ComputeOnsOffs(WE_s_1);
    WE_s_1_summary = size(WE_s_1_ons);
    WE_s_1_summary = WE_s_1_summary(1);
    
    WE_female = WE(2,:);
    WE_female(isnan(WE(2,:))) = 0;
    WE_s_2 = remove_n_consecutive (WE_female, 0);
    WE_frames_2 = sum (WE_s_2);
    [WE_s_2_ons,~] = ComputeOnsOffs(WE_s_2);
    WE_s_2_summary = size(WE_s_2_ons);
    WE_s_2_summary = WE_s_2_summary(1);
    
    
    sz_we = size(WE_s_1_ons);
    if sz_we(1)>0
        first_WE_1 = (WE_s_1_ons(1) - StartTracking)/fps;
    else
        first_WE_1 = -1;
    end
    
    sz_we = size(WE_s_2_ons);
    if sz_we(1)>0
        first_WE_2 = (WE_s_2_ons(1) - StartTracking)/fps;
    else
        first_WE_2 = -1;
    end
    
    
    cop = find(fly_apart_error_s == 99);
    is_cop = ~isempty(cop);
    % keyboard;
    if is_cop
        first_cop = (cop(1) - StartTracking)/fps;
    else
        first_cop = (StopTracking - StartTracking)/fps;
    end
    
    total_time = (StopTracking - StartTracking)/fps;
    
    % keyboard;
    n_agg =0;
    first_agg = -1;
    if exist('agg_s', 'var') == 1   
        n_agg = sum(agg_s);
        
        first_agg_index = find(agg_s, 1);
        if ~isempty(first_agg_index)
            first_agg = (first_agg_index - StartTracking)/fps;
        
        end
    end
    
    total_time = (StopTracking - StartTracking)/fps;
    
    sz = size(result_database);
    addhere = sz(1)+1;
    
    result_database{addhere,1} = allfiles(fi).name;
    result_database{addhere,2} = mean_speed_1_summary;
    result_database{addhere,3} = mean_speed_2_summary;
    result_database{addhere,4} = min_body_dist_summary;
    result_database{addhere,5} = collisions_summary;
    result_database{addhere,6} = WE_s_1_summary;
    result_database{addhere,7} = WE_s_2_summary;
    result_database{addhere,8} = WE_frames_1;
    result_database{addhere,9} = WE_frames_2;
    result_database{addhere,10} = first_WE_1;
    result_database{addhere,11} = first_WE_2;
    result_database{addhere,12} = total_time;
    disp(allfiles(fi).name),disp('finished')
    
    clearvars -except allfiles fi result_database;
    
end

savename = strcat('Results_',foldername);
xlswrite(savename,result_database);

