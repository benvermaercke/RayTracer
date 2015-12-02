clear all
clc

clf
%% find linear part where sin and asin are inverse of each other

%X=linspace(-1,1,20);
X=linspace(-pi/2,pi/2,200);

Y1=sin(X);
Y2=asin(Y1);

plot(X,Y2)

%X-Y2

%%

alpha=250/180*pi;

[alpha sin(alpha) constrain_angle(alpha)]/pi*180% asin(constrain_angle(alpha))]

constrain_angle(alpha)

%% max angle that gives valid asin
asin(sin(57/180*pi))


