clear all
clc

IOR_air=1.00029;
IOR_glass=1.517;

TH_in=45; % difference between incoming beam and normal on surfaces


% n1 ? sin ( ?1 ) = n2 ? sin (?2)
TH_out=(IOR_air*sin(TH_in/180*pi)) / IOR_glass /pi*180
TH_out_GA=(IOR_glass*sin(TH_out/180*pi)) / IOR_air/pi*180

%%% Description of the lens => intersection of two circles (assume equal
%%% radii for now)
circle1.center=[40 0]; % focal point on right side of mirror
circle1.radius=40;
radius_1=40;
radius_2=radius_1;

% base point
center = [10 0];
% create vertical line
l1 = [center 0 1];
% circle
c1 = [center 5];
pts = intersectLineCircle(l1, c1)



segment_angle=30;
segment_angle_rad=segment_angle/180*pi;
nPoints=100;
RHO=ones(1,nPoints)*radius_1;
THETA=linspace(-segment_angle_rad,segment_angle_rad,nPoints);

[X, Y]=pol2cart(THETA,RHO);

NORMAL=THETA-pi;

clf
hold on
circle([40 0],radius_1,200,'r--',1);
circle([-30 0],radius_1,200,'r--',1);

line([-100 100],[0 0],'color','k')
line([0 -TH_in],[0 TH_in],'color','g')
line([0 TH_in],[0 -TH_out],'color','g')



plot(X-30,Y,'lineWidth',2)
plot(-X+40,Y,'lineWidth',2)
axis([-100 100 -50 50])
axis equal



