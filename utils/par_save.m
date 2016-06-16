function [] =  par_save(fname, posx, posy, orientation, area, MajorAxis, MinorAxis, WE, collisions, min_body_dist_s, fly_apart_error_s, StartTracking, StopTracking, moviefile, ROIs, thresh_ROIs, Channel,distant_wing_area_s)    

save(fname,'posx','posy','orientation','area','MajorAxis','MinorAxis','WE','collisions','min_body_dist_s','fly_apart_error_s','StartTracking','StopTracking','moviefile','ROIs','thresh_ROIs','Channel','distant_wing_area_s')

end

