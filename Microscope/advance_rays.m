function out=advance_rays(Rays,iRay)

out=Rays.next_position(iRay,:)+Rays.step_size*[cos(Rays.cur_angle(iRay)) sin(Rays.cur_angle(iRay))];
