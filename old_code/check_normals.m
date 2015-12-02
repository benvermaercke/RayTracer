clear all
clc

center=[0 0];

THETA=linspace(0,pi*2,100)';
RHO=ones(length(THETA),1)*4;

[X,Y]=pol2cart(THETA,RHO);
X=X+center(1);
Y=Y+center(2);

iPoint=100;

point_x=X(iPoint);
point_y=Y(iPoint);
normal_expected=THETA(iPoint);

normal_check=calc_heading([center point_x point_y]);

disp([normal_expected normal_check]/pi*180)
[sin([normal_expected normal_check])]

clf
plot(X,Y,'.')
hold on
plot(center(1),center(2),'m*')
plot(point_x,point_y,'m*')


l=5;
x1=point_x-l*cos(normal_expected);
y1=point_y-l*sin(normal_expected);
x2=point_x+l*cos(normal_expected);
y2=point_y+l*sin(normal_expected);
plot([x1 x2],[y1 y2],'m-')

hold off
axis equal

