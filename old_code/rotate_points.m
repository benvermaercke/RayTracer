function out=rotate_points(in,center,angle)

[theta, rho]=cart2pol(in(:,1)-center(1),in(:,2)-center(2));

theta=theta+angle;

[X,Y]=pol2cart(theta,rho);

out=[X+center(1),Y+center(2)];