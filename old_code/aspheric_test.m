clear all
clc

R=-[-50 50]/4;
kappa=0;
thickness=4;
height=25.4/2;
nPoints=100;

X=linspace(-height/2,height/2,nPoints);
XV=[];
YV=[];
N=[];
for iSurface=1:2
    Y=X.^2 ./ (R(iSurface) * (1 + sqrt(1-(1+kappa)*X.^2/R(iSurface)^2) ) ) ;
    Y=Y(:);
    if iSurface==1
        Y=Y'-thickness/2;
    else
        Y=(Y'+thickness/2);
        X=-X;
    end
    
    % get normals
    normals=zeros(nPoints,1);
    for iPoint=2:nPoints-1
        point=[Y(iPoint) X(iPoint)];
        neighbors=[X([iPoint-1 iPoint+1]) ;  Y([iPoint-1 iPoint+1])];        
        % use neighbor to estimate normal
        alpha=calc_heading(neighbors(:));
        normals(iPoint)=alpha+pi/2;
        %alpha/pi*180
    end
    
    if 0
        %%
        % or inversely, try to get a sence of what rho is required to make an
        % asphere instead of regular circle with constant rho
        center=[0 R(iSurface)];
        clf
        D=calc_dist([X(:) Y(:) repmat(center,nPoints,1)]);
        plot(D-(R(1)+thickness/2))
        title(std(D))
    end
    
    
    XV=cat(1,XV,Y(:));
    YV=cat(1,YV,X(:));
    N=cat(1,N,normals);

    plot(X,normals)
end


%%

XV(end+1)=XV(1);
YV(end+1)=YV(1);

clf
hold on
plot(XV,YV)
drawCircle([R(1)-thickness/2 0],R(1),'r')
axis equal