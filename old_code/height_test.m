clear all
clc

count=1;
for radius=12.701%:4:150
    %%
    center=[0 0];
    
    height=25.4;
    
    if height/2>radius
        %error('Half height larger than radius, not possible')
    end
    
    %%% find analytical coordinate
    l1=[0 height/2 1 0];
    c1=[0 0 radius];
    %drawLine(l1)
    %drawCircle(c1)
    intersect_points=intersectLineCircle(l1,c1);
    coord=intersect_points(2,:);
    max_angle=atan((height/2)/(intersect_points(2,1)));
    factor=coord(1)/radius;
    clf
    hold on
    circle(center,radius,100,'r',1);
    plot([0 radius*factor],[0 0],'k-')
    %plot([radius radius],[-height/2 height/2],'k-')
    plot([radius radius]*factor,[-height/2 height/2],'k-')
    
    plot([0 radius*2],[height/2 height/2],'k:')
    plot([0 radius*2],-[height/2 height/2],'k:')
    
    plot([0 radius*factor],[0 height/2],'k-')
    
    
    
    
    dataMatrix(count,:)=[count radius max_angle max_angle/pi*180];
    count=count+1;
    axis equal
    title(max_angle/pi*180)
end

%%
clf
X=dataMatrix(:,2);
Y=dataMatrix(:,4);

[xFit,yFit,coeffs]=dataFitting(X,Y,'hyperbol',[1 0 0 0]);
hold on
plot(X,Y)
plot(xFit,yFit,'r')
coeffs



