
%MANUAL_CORRECTION Summary of this function goes here
%   Detailed explanation goes here
function []  = check_correction()



allfiles_ori = uigetfile('*.mp4','MultiSelect','on');

if ~ischar(allfiles_ori)
    allfiles = cell2struct(allfiles_ori,'name');
else
    allfiles = struct;
    allfiles(1).name = allfiles_ori;
end



mi = 1;
L = load(strcat(allfiles(mi).name(1:end-4),'_crrcted','.','mat'));
moviefile = L.moviefile;
movie = VideoReader(moviefile);
nframes = get(movie,'NumberOfFrames');
startframe = L.StartTracking;
frame = startframe;
moviefigure =[];
f1 = [];
framecontrol = [];
framecontrol2 = [];
switchbutton=[];
cop_button = [];
nextfilebutton=[];
skipthisbutton=[];
th=[];
jump2start = [];
jump2stop = [];
fwd200 = [];
bckwd200 = [];




CreateGUI;
showimage;





    function [] = CreateGUI(eo,ed)
        titletext = allfiles(mi).name;
        
        moviefigure = figure('Position',[150 250 900 600],'Name',titletext,'Toolbar','none','Menubar','none','NumberTitle','off','Resize','off','HandleVisibility','on','KeyPressFcn', @keyPress);
        f1 = figure('Position',[150 70 900 100],'Toolbar','none','Menubar','none','NumberTitle','off','Resize','on','HandleVisibility','on','KeyPressFcn', @keyPress);
        
        framecontrol = uicontrol(f1,'Position',[53 45 550 20],'Style','slider','Value',startframe,'Min',7,'Max',nframes,'SliderStep',[1/nframes 10/nframes],'Callback',@framecallback);
        th(1)=uicontrol(f1,'Position',[1 45 50 20],'Style','text','String','frame #');
        
        framecontrol2 = uicontrol(f1,'Position',[383 5 60 20],'Style','edit','String',mat2str(frame),'Callback',@frame2callback);
        th(2)=uicontrol(f1,'Position',[320 5 60 20],'Style','text','String','frame #');
        
        
        switchbutton = uicontrol(f1,'Position',[750 40 120 30],'Style','pushbutton','String','Switch 1&2','Callback',@swithch_fly_callback);
        
        cop_button = uicontrol(f1,'Position',[750 10 120 30],'Style','pushbutton','String','Mark Cop','Callback',@cop_callback);
        
        nextfilebutton = uicontrol(f1,'Position',[223 5 50 30],'Style','pushbutton','String','Next File','Enable','on','Callback',@nextcallback);
        
        skipthisbutton = uicontrol(f1,'Position',[123 5 50 30],'Style','pushbutton','String','Skip This','Enable','on','Callback',@cannotanalysecallback);
        
        jump2start = uicontrol(f1,'Position',[450 5 80 30],'Style','pushbutton','String','Jump to Start','Enable','on','Callback',@jump2start_callback);
        jump2stop = uicontrol(f1,'Position',[550 5 80 30],'Style','pushbutton','String','Jump to Stop','Enable','on','Callback',@jump2stop_callback);

        fwd200 = uicontrol(f1,'Position',[630 40 80 30],'Style','pushbutton','String','--> 200','Enable','on','Callback',@fwd200_callback);
        bckwd200 = uicontrol(f1,'Position',[630 10 80 30],'Style','pushbutton','String','<-- 200','Enable','on','Callback',@bckwd200_callback);
        
    end



    function [] = nextcallback(eo,ed)
        disp('next call back running')
%         L.is_manual_corrected = 1;
        savetrackdata;
        
        if mi == length(allfiles)
            delete(moviefigure)
            delete(f1)
        else
            % clear all old variables
            disp('OK. Next file.')
            disp(allfiles(mi).name),disp('finished')
            
            % delete all GUI elements
            delete(framecontrol)
            delete(framecontrol2)
            delete(switchbutton)
            delete(nextfilebutton)
            delete(skipthisbutton)
            delete(th(1))
            delete(th(2))
            delete(cop_button)
            delete(moviefigure)
            delete(f1)
            delete(jump2start)
            delete(jump2stop)
            delete(fwd200)
            delete(bckwd200)
            
            % redraw entire GUI
            clearvars -except allfiles mi;
            
            mi = mi+1;
            movie = VideoReader(allfiles(mi).name);
            nframes = get(movie,'NumberOfFrames');
            L = load(strcat(allfiles(mi).name(1:end-4),'_crrcted','.','mat'));
            
            
            
            
            startframe = L.StartTracking;
            frame = startframe; % current frame
            %             delete(framecontrol)
            %             framecontrol = uicontrol(f1,'Position',[53 45 600 20],'Style','slider','Value',startframe,'Min',7,'Max',nframes,'SliderStep',[1/nframes 10/nframes],'Callback',@framecallback);
            
            
            
            CreateGUI;
            
            % update GUI
            titletext = allfiles(mi).name;
            set(moviefigure,'Name',titletext);
            set(framecontrol,'Value',startframe);
            framecallback            
            showimage;
            disp(allfiles(mi).name),disp('started')
            
        end
    end


    function keyPress(eo,ed)
        switch ed.Key
            case 'c'
                fwd200_callback(fwd200, []);
            case 'x'
                bckwd200_callback(bckwd200,[]);
        end
    end
        


    function [] = cannotanalysecallback(eo,ed)
        % move this to cannot-analyse
        if exist('cannot-manual-corrected','dir') == 0 %7 in exist() return means directory
           % make it when no 'cannot-analyse' folder
            mkdir('cannot-manual-corrected')
        end
        % move the movie and mat data to a subfolder cannot-manual-corrected
        thisfile = allfiles(mi).name;
        movefile(thisfile,strcat('cannot-manual-corrected',oss,thisfile))
       
        
        movefile(strcat(thisfile(1:end-4),'_anno','.mat'),strcat('cannot-manual-corrected',oss,strcat(thisfile(1:end-4),'_anno','.mat')))
        try
            movefile(strcat(thisfile(1:end-4),'_crrcted','.mat'),strcat('cannot-manual-corrected',oss,strcat(thisfile(1:end-4),'_crrcted','.mat')))
        catch
            disp('Correction file has not been generated. Do not need to move.')
        end
        nextcallback;
    end



    function [] = framecallback(eo,ed)
        frame = ceil((get(framecontrol,'Value')));
        showimage();
        set(framecontrol2,'String',mat2str(frame));
    end




    function [] = frame2callback(eo,ed)
        frame = ceil(str2double(get(framecontrol2,'String')));
        showimage();
        set(framecontrol,'Value',(frame));
    end

    function [] = fwd200_callback(eo,ed)
        frame = frame +200;
        set(framecontrol,'Value',(frame));
        framecallback;
        showimage();
    end

    function [] = bckwd200_callback(eo,ed)
        frame = frame -200;
        set(framecontrol,'Value',(frame));
        framecallback;
        showimage();
    end


        


    function [] = swithch_fly_callback(eo,ed)
        frame = ceil(str2double(get(framecontrol2,'String')));
        %keyboard;
%         disp(L.posx(1,frame))
%         disp(L.posx(2,frame))
%         
        
        L.posx = switch_1_2(L.posx);
        
%         disp(L.posx(1,frame))
%         disp(L.posx(2,frame))
        
        
        L.posy = switch_1_2(L.posy);
        L.WE = switch_1_2(L.WE);
        L.orientation = switch_1_2(L.orientation);
        L.MajorAxis = switch_1_2(L.MajorAxis);
        L.MinorAxis = switch_1_2(L.MinorAxis);
        L.area = switch_1_2(L.area);
        
        
        savetrackdata;
        L = load(strcat(allfiles(mi).name(1:end-4),'_crrcted','.mat'));
        showimage();
        
        %keyboard;
        
    end


    function [] = cop_callback(eo,ed)
        for fm = frame:L.StopTracking
            if ~isnan(L.posx(1,fm))
                L.posx(2,fm) = L.posx(1,fm);
            else
                L.posx(1,fm) = L.posx(2,fm);
            end
            
            if ~isnan(L.posy(1,fm))
                L.posy(2,fm) = L.posy(1,fm);
            else
                L.posy(1,fm) = L.posy(2,fm);
            end
            L.WE(1,fm) = NaN;
            L.WE(2,fm) = NaN;
            L.collisions(fm) = 1;
            L.fly_apart_error_s(fm) = 99;
        end
        showimage();
        savetrackdata;
    end
    

    function [] = jump2start_callback(eo,ed)
        set(framecontrol,'Value',L.StartTracking)
        framecallback        
    end

    function [] = jump2stop_callback(eo,ed)
        set(framecontrol,'Value',L.StopTracking)
        framecallback
    end
        

    function [] = showimage(eo,ed)
        ff = read(movie,frame);        
        fly_1_x = max(0,L.posx(1,frame));
        fly_2_x = max(0,L.posx(2,frame));
        fly_1_y = max(0,L.posy(1,frame));
        fly_2_y = max(0,L.posy(2,frame));
        
        fly_ID_insert = vision.TextInserter('%s', 'LocationSource', 'Input port', 'Color',  [255, 0, 0], 'FontSize', 24);
        strings_fly_ID = uint8(['M' 0 'F']);
        
        ff = step(fly_ID_insert, ff, strings_fly_ID, int32([fly_1_x fly_1_y;fly_2_x fly_2_y]));
        
        if frame > L.StopTracking
            fly_stop_insert = vision.TextInserter('%s', 'LocationSource', 'Input port', 'Color',  [255, 0, 0], 'FontSize', 50);
            strings_stop = uint8('Tracking Stopped');
            ff = step(fly_stop_insert, ff, strings_stop, int32([80,240]));
        end
        
        figure(moviefigure), axis image
        imagesc(ff);
        title(frame);
        
        

    end

    function  [] = savetrackdata(eo,ed)
        filename = allfiles(mi).name;
        
        posx = L.posx;
        posy = L.posy;
        WE = L.WE;
        orientation = L.orientation;
        MajorAxis = L.MajorAxis;
        MinorAxis = L.MinorAxis;
        area = L.area;        
        moviefile = allfiles(mi).name;
        
%         is_manual_corrected = L.is_manual_corrected;
        fly_apart_error_s = L.fly_apart_error_s;
        collisions = L.collisions;
        ROIs = L.ROIs;
        StartTracking = L.StartTracking;
        StopTracking = L.StopTracking;
        thresh_ROIs = L.thresh_ROIs;
        Channel = L.Channel;
        min_body_dist_s = L.min_body_dist_s;
        
        
        
        
        save(strcat(filename(1:end-4),'_crrcted','.mat'),'posx','posy','WE',...
            'orientation','MajorAxis','MinorAxis','area','moviefile',...
            'fly_apart_error_s','collisions','ROIs','StartTracking',...
            'StopTracking','thresh_ROIs','Channel','min_body_dist_s');
        disp('saved');
    end

    function M_2_by_n = switch_1_2(M_2_by_n)
        for fm = frame:L.StopTracking
            temp = M_2_by_n(1,fm);
            M_2_by_n(1,fm) = M_2_by_n(2,fm);
            M_2_by_n(2,fm) = temp;
        end
        disp('Swith done')
    end

end



