clear all
clc

addpath('/Users/benvermaercke/Google Drive/tools/geom2d/geom2d')


% create bundle of rays
switch 2
    case 1 % spotlight
        nRays=15;
        p=[-2 4];
        theta=linspace(pi/8,-pi/8,nRays);
    case 2 % parallel bundel
        nRays=15;
        p=[linspace(0,0,nRays)'  linspace(1,5,nRays)'];
        theta=-pi/8;
end
l1=createBundle(p,theta);

% circle
c1 = [10 0 5];
N=size(l1,1);
pts=[];
for index=1:N
    pts = cat(1,pts,intersectLineCircle(l1(index,:), c1));
end

% draw the result
figure(1); clf; hold on;
axis([0 20 -10 10]);

axis equal;
drawLine(l1);
drawCircle(c1);
drawPoint(pts, 'rx');
