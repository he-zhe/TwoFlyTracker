% AnnotateVideo.m
% created by Srinivas Gorur-Shandilya at 13:46 , 28 August 2013. Contact me
% at http://srinivas.gs/contact/
% AnnotateVideo.m is a master GUI that is meant to annotate fly movies with
% information that a tracking algo can use to automatically track fly
% trajectories.
% ---------------------------------------------------
% This fuction will generate ROI, StartTracking and StopTracking(frame).
% Also a thresh ROI will be generated to make threshold more accurate.
% ---------------------------------------------------
% This function was modified by Zhe He on 8/13/2015: 
% 1. This function will only account for one-arena videos. Also, a threshold
% 2. Thresh ROI button was added to select a single fly, which can help generate more
% accurate threshold for multithresh analysis (to differentiate background, wing, and body)
% 3. In ROIcallback, the circlefit was replaced by using getPosition
% method.
% 4. Minor changes in UI(Color, size, etc )
%
%----------------------------------------------------
% New function added on 8/20/2015:
% There's a new button/call back that can detect the arena automatically.

function []  = AnnotateVideo(source,thesefiles)
%% global parameters
global n
startframe = 100;
frame = 100; % current frame
StartTracking = [];
StopTracking  = [];

ROIs=  []; % Row1 is x; Row2 is y; Row3 is radius
thresh_ROIs = [];
Channel = 3;

nframes=  [];
h = [];
movie = [];
mi= [];
moviefile= [];

% figure and object handles
moviefigure= [];
f1=  [];
framecontrol = [];
framecontrol2= [];
markstartbutton = [];
markstopbutton = [];

markroibutton = [];
auto_roi_button = [];
mark_thresh_roi_button = [];
nextfilebutton = [];
skipthisbutton = [];
channelcontrol = [];

th = []; % text handles, allowing rapid deletion







%% choose files
if nargin == 0
    source = cd;
    allfiles = uigetfile('.avi','MultiSelect','on'); % makes sure only avi files are chosen
    if ~ischar(allfiles)
        % convert this into a useful format
        thesefiles = [];
        for fi = 1:length(allfiles)
            thesefiles = [thesefiles dir(strcat(source,oss,cell2mat(allfiles(fi))))];
        end
    else
        thesefiles(1).name = allfiles;
    end
else
    cd(source)
end


mi=1;
InitialiseAnnotate(mi);
skip=0;




%% make GUI function

    function [] = CreateGUI(eo,ed)
        titletext = thesefiles(mi).name;
        moviefigure = figure('Position',[150 250 900 600],'Name',titletext,'Toolbar','none','Menubar','none','NumberTitle','off','Resize','off','HandleVisibility','on');
        
        f1 = figure('Position',[150 70 900 100],'Toolbar','none','Menubar','none','NumberTitle','off','Resize','on','HandleVisibility','on');
                        
        framecontrol = uicontrol(f1,'Position',[53 45 550 20],'Style','slider','Value',startframe,'Min',1,'Max',nframes,'SliderStep',[1/nframes 10/nframes],'Callback',@framecallback);
        th(1)=uicontrol(f1,'Position',[1 45 50 20],'Style','text','String','frame #');
        
        framecontrol2 = uicontrol(f1,'Position',[383 5 60 20],'Style','edit','String',mat2str(frame),'Callback',@frame2callback);
        th(2)=uicontrol(f1,'Position',[320 5 60 20],'Style','text','String','frame #');
        
        channelcontrol = uicontrol(f1,'Position',[503 5 60 20],'Style','edit','String','3');
        th(3)=uicontrol(f1,'Position',[450 5 60 20],'Style','text','String','channel #');
        
        
        markstartbutton = uicontrol(f1,'Position',[650 10 80 30],'Style','pushbutton','String','Mark Start','Callback',@markstart);
        markstopbutton = uicontrol(f1,'Position',[650 50 80 30],'Style','pushbutton','String','Mark Stop','Callback',@markstop);
        
        auto_roi_button = uicontrol(f1,'Position',[750 5 120 30],'Style','pushbutton','String','Detect ROIs','Callback',@auto_roi_callback);
        
        markroibutton = uicontrol(f1,'Position',[750 40 120 30],'Style','pushbutton','String','Mark ROIs','Callback',@markroi);
        
        mark_thresh_roi_button = uicontrol(f1,'Position',[750 70 120 30],'Style','pushbutton','String','Mark Thresh_ROIs','Callback',@mark_thresh_roi);
        
        nextfilebutton = uicontrol(f1,'Position',[223 5 80 30],'Style','pushbutton','String','Next File','Enable','on','Callback',@nextcallback);
        
        skipthisbutton = uicontrol(f1,'Position',[123 5 80 30],'Style','pushbutton','String','Skip This','Enable','on','Callback',@cannotanalysecallback);
    end

    function [] = cannotanalysecallback(eo,ed)
        % move this to cannot-analyse
        if exist('cannot-analyse','dir') == 0 %7 in exist() return means directory
           % make it when no 'cannot-analyse' folder
            mkdir('cannot-analyse')
        end
        % move this file there
        movefile(thesefiles(mi).name,strcat('cannot-analyse',oss,thesefiles(mi).name))
        % delete the .mat
        thisfile = thesefiles(mi).name;
        delete(strcat(thisfile(1:end-4),'_anno','.','mat')) %(1:end-4) removes the ".mp4"
        % go to the next file
        skip=1;
        nextcallback;
        skip=0;
    end

    function [] = nextcallback(eo,ed)
        if mi == length(thesefiles) %last file finished
            delete(moviefigure)
            delete(f1)
            fprintf('All Done\n')
        else
            % clear all old variables
            disp('OK. Next file.')
            
            
            % delete all GUI elements
            delete(framecontrol)
            delete(framecontrol2)
            delete(channelcontrol)

            delete(auto_roi_button)
            delete(markroibutton)
            delete(mark_thresh_roi_button)
            delete(markstartbutton)
            delete(markstopbutton)
            delete(nextfilebutton)
            delete(skipthisbutton)
            delete(th(1),th(2),th(3));
            delete(moviefigure)
            delete(f1)
            
            % redraw entire GUI
            CreateGUI;
            
            nframes=  [];
            h = [];
            moviefile= [];
            
            
            mi = mi+1;
            movie = VideoReader(thesefiles(mi).name);
            h =  get(movie,'Height');
            
            % working variables
            nframes = get(movie,'NumberOfFrames');
            
            % clear variables
            if ~skip
                frame=100;
                markroi; % clears ROIs
                mark_thresh_roi;
                markstart;
                markstop;
            end
            
            startframe = 100;
            frame = 100; % current frame
            StartTracking = [];
            StopTracking  = [];

            ROIs=  []; % Row1 is x; Row2 is y; Row3 is radius
            thresh_ROIs = [];
            delete(framecontrol)
            
            framecontrol = uicontrol(f1,'Position',[53 45 550 20],'Style','slider','Value',startframe,'Min',1,'Max',nframes,'SliderStep',[1/nframes 10/nframes],'Callback',@framecallback);
            
            
            % update GUI
            titletext = thesefiles(mi).name;
            set(moviefigure,'Name',titletext);
            set(framecontrol,'Value',100);
            framecallback
            
            showimage;
            
        end
    end


%% intialise function

    function [] = InitialiseAnnotate(mi)
        
        
        movie = VideoReader(thesefiles(mi).name);
        h =  get(movie,'Height');
        
        % working variables
        % Some video cannot jump to the last frame
        nframes = get(movie,'NumberOfFrames') - 5;
        
        CreateGUI;
        
        
        showimage;
        
    end



%% callback functions
    function [] = auto_roi_callback(eo,ed)
        if isempty(ROIs)
            ROIs = NaN(3,1);
            figure(moviefigure), axis image
            ff = read(movie,frame);
            ff = ff (:,:,Channel);
            thresh = multithresh(ff,2);
            ff(ff<thresh(2)) = 0;
            ff(ff>=thresh(2)) = 1;     
            
            BW2 = imfill(logical(ff),'holes');
            BW2 = bwareafilt(BW2,1);
            bd = bwboundaries(BW2,'nohole');
            %keyboard;
            [xc,yc,R,~] = circfit(bd{1,1}(:,2),bd{1,1}(:,1));
            ROIs = [xc;yc;R*0.98];
                                   
            showimage;
            set(auto_roi_button,'String','ROIs Marked','BackgroundColor',[1 0 0])
            set(markroibutton,'String','ROIs Marked','BackgroundColor',[1 0 0])
        else
            ROIs= [];
            set(markroibutton,'String','Mark ROIs','BackgroundColor',[1 1 1])
            set(auto_roi_button,'String','Detect ROIs','BackgroundColor',[1 1 1])
            showimage;
        end
        savetrackdata;      
    end 
    
    
    
    function [] = markroi(eo,ed)
        if isempty(ROIs)
            ROIs = NaN(3,1);
            figure(moviefigure), axis image

            [he]=imellipse('PositionConstraintFcn',@(pos) [pos(1) pos(2) max(pos(3:4)) max(pos(3:4))]);
            wait(he);
            if ~isempty(he)
                [position] = getPosition(he);
                ROIs(:,1) = [position(1)+position(3)/2 position(2)+position(3)/2 position(3)*0.98/2];

                showimage;
                set(markroibutton,'String','ROIs Marked','BackgroundColor',[1 0 0])
                set(auto_roi_button,'String','ROIs Marked','BackgroundColor',[1 0 0])
            end

        else
            ROIs= [];
            set(markroibutton,'String','Mark ROIs','BackgroundColor',[1 1 1])
            set(auto_roi_button,'String','Detect ROIs','BackgroundColor',[1 1 1])

            showimage;
        end
        savetrackdata;      
    end

    function [] = mark_thresh_roi(eo,ed)
        
        if isempty(thresh_ROIs)
            thresh_ROIs = NaN(3,1);
            figure(moviefigure), axis image
            
            [he]=imellipse('PositionConstraintFcn',@(pos) [pos(1) pos(2) max(pos(3:4)) max(pos(3:4))]);
            setColor(he,'w')
            wait(he);
            position = getPosition(he);
            thresh_ROIs(:,1) = [position(1)+position(3)/2 position(2)+position(3)/2 position(3)/2];
            showimage;
            
            set(mark_thresh_roi_button,'String','Thresh_ROIs Marked','BackgroundColor',[0 1 0])
                       
        else
            thresh_ROIs= [];
            set(mark_thresh_roi_button,'String','Mark Thresh_ROIs','BackgroundColor',[1 1 1])
            showimage;
        end
        savetrackdata;
        
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

    function [] = showimage(eo,ed)
        ff = read(movie,frame);
        Channel = str2num(get(channelcontrol,'String'));
        
        ff = 255-ff(:,:,Channel);
        figure(moviefigure), axis image
        imagesc(ff); colormap(gray)
        axis equal
        axis tight
        title(frame)
        savetrackdata;
        % try to draw the circles
        if ~isempty(ROIs)
            viscircles(ROIs(1:2,:)',ROIs(3,:),'EdgeColor','r');
        end
        
        if ~isempty(thresh_ROIs)
            viscircles(thresh_ROIs(1:2,:)',thresh_ROIs(3,:),'EdgeColor','g');
        end
    end



    function  [] = markstart(eo,ed)
        if ~isempty(StartTracking)
            StartTracking = [];
            set(markstartbutton,'String','Mark start','BackgroundColor',[1 1 1])
        else            
            StartTracking = frame;
            set(markstartbutton,'String','Start Marked','BackgroundColor',[1 1 0])
        end
        savetrackdata;
    end

    function  [] = markstop(eo,ed)
        if ~isempty(StopTracking)
            StopTracking = [];
            set(markstopbutton,'String','Mark stop','BackgroundColor',[1 1 1])
        else
            StopTracking = frame;
            set(markstopbutton,'String','Stop Marked','BackgroundColor',[1 1 0])
        end
        savetrackdata;
    end

    function  [] = savetrackdata(eo,ed)
        Channel = str2num(get(channelcontrol,'String'));
        moviefile = thesefiles(mi).name;
        filename = thesefiles(mi).name;
        save(strcat(filename(1:end-4),'_anno','.','mat'),'StartTracking','StopTracking','moviefile','ROIs','thresh_ROIs','Channel');
        if  ~isempty(StartTracking) && ~isempty(StopTracking) && ~isempty(ROIs) && ~isempty(thresh_ROIs)
            set(nextfilebutton,'Enable','on');
            set(skipthisbutton,'Enable','off');
        else
            set(nextfilebutton,'Enable','off');
            set(skipthisbutton,'Enable','on');
        end        
    end

end