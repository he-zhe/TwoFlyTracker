% created by Srinivas Gorur-Shandilya at 19:42 , 04 December 2013. Contact me at http://srinivas.gs/contact/
% builds a logical matrix the size of the frame based on circular ROIs
function [mask] = ROI2mask(ff,ROIs)
%disp('Building ROI mask...')
mask = squeeze(0*ff(:,:,1));
for i = 1:size(ff,2)
    for j =1:size(ff,1)
        maskthis = 0;
        for k = 1:size(ROIs,2)
            maskthis = maskthis + ((i-ROIs(1,k))^2 + (j-ROIs(2,k))^2 < ROIs(3,k)^2);
        end
        mask(j,i) = maskthis;
    end
end
%disp('DONE')
end