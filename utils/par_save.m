function [] =  par_save(fname, posx, posy, orientation, area, MajorAxis, MinorAxis, WE, collisions, min_body_dist_s, fly_apart_error_s, StartTracking, StopTracking, moviefile, ROIs, thresh_ROIs, Channel)    

save(fname,'posx','posy','orientation','area','MajorAxis','MinorAxis','WE','collisions','min_body_dist_s','fly_apart_error_s','StartTracking','StopTracking','moviefile','ROIs','thresh_ROIs','Channel')

end

