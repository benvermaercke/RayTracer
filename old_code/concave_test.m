clear all
clc


thickness=5;
%%% start from 2 points that define distance between surfaces (thickness)
center_points=[-thickness/2 thickness/2];

%%% draw cicle through each point. Move center away by radii, can be
%%% positive or negative (defines direction relative to direction of light)
radii=[50 50];

centers=[center_points+radii];
clf
hold on
plot(center_points,[0 0],'m*')
plot(centers, [0 0],'co')

for index=1:2
    circle([centers(index) 0],radii(index),100,'r',1)
end
axis equal

