allfiles_ori = uigetfile('*crrcted.mat','MultiSelect','on');

if ~ischar(allfiles_ori)
    allfiles = cell2struct(allfiles_ori,'name');
else
    allfiles = struct;
    allfiles(1).name = allfiles_ori;
end

vnum = 0;

for fi =1:length(allfiles)
    load(allfiles(fi).name);
    
    real_WE = zeros(size(WE));
    
    vnum = vnum + 1;
    disp( 'This is video No.');
    disp(vnum);
    % loop through fly 1 and 2
    last_x = 0.0;
    last_y = 0.0;
    for WE_i = 1:2
        each_fly_WE = WE(WE_i,:);
        sz = size(each_fly_WE);
        sz = sz(2);
        fprintf( 'This is fly No.%d\n', WE_i);
%         disp(WE_i);
        
        % initialize a 1-d array to save the real WE data
        
        
        Counter = [];
        % dist = [];
        movie = VideoReader(moviefile);
        i = 1;
        while i <= sz
            if each_fly_WE(i) == 1
                count = 0;
                walk = i;
                while walk < sz && each_fly_WE(walk) == 1
                    count = count + 1;
                    walk = walk + 1;
                end
                Counter = [Counter, count];
                
                if count >5
                    disp(pdist([posx(WE_i, i), posy(WE_i, i);last_x,last_y]));
                    if pdist([posx(WE_i, i), posy(WE_i, i);last_x,last_y]) < 20
                        i = walk + 1;
                        continue;
                    end
                    
                    while 1
                        for fm = i:3:walk-1
                            ff = read(movie,fm);
                            ff_label = insertText(ff,[posx(WE_i, fm)-10, posy(WE_i, fm)-10],'here');
                            
                            imshow(ff_label);
                        end
                        prompt = 'Do you want to stop? Y/N [Y]: ';
                        if_stop = input(prompt,'s');
                        if isempty(if_stop) || if_stop == 'Y' || if_stop == 'y'
                            break;
                        end
                    end
                    
                    prompt = 'Do you think this is real WE? Y/N [N]: ';
                    if_real = input(prompt,'s');
                    if (if_real == 'Y') | (if_real == 'y')
                        real_WE(WE_i, i:walk-1) = 1;
                        last_x = 0;
                        last_y = 0;
                    else
                        disp('Not real WE, posx,y recorded');
                        last_x = posx(WE_i, i);
                        last_y = posy(WE_i, i);
                    end
                    
                    disp( [ 'You just watched frame No.' num2str( i )]);
                    disp(' ');
                end
                i = walk + 1;
            else
                i = i + 1;
            end
        end
    end
    
    save(allfiles(fi).name,'real_WE','-append')
    clearvars -except allfiles fi vnum;
    
end
% disp(mean(dist))
% disp(counter);
% hist(Counter,unique(Counter));