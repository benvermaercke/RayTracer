function lens_object=create_lens_f(varargin)

if nargin==0
    lens_options=default_lens;
else
    lens_options=varargin{1};
end

%%% Start by creating two circles with radii defined by focal length of
%%% front and back surface
F=lens_options.focal_length;
n=lens_options.index_of_refraction;
n_0=lens_options.medium_index_of_refraction;

% derive radii from desired focal length
sum_R=F*2*((n-n_0)/n_0);
R=[sum_R sum_R];

% check solution
P=(n-n_0)/n_0 * ( 1/R(1) - -1/R(2) );
if 1/P==F
    
else
    error('error in calculation')
end

% now place both at a certain distance apart
d=lens_options.thickness;
L=sum(R)-d;

% % define two circles that will make up the edges of the lens
% R=[lens_options.thickness lens_options.thickness]/lens_options.lens_strength;
% L=sum(R)-lens_options.thickness;

if L<10
    error('Combination of radii and thickness gives improper results')
end

L1=R(1)-d*(R(1)/sum(abs(R)));
L2=abs(R(2)-d*(R(2)/sum(abs(R))));
C=[-L1*cos(lens_options.angle) -L1*sin(lens_options.angle); L2*cos(lens_options.angle) L2*sin(lens_options.angle)];
C=C+repmat(lens_options.spatial_location,2,1);

%%% Get focal length using lensmakers equation for thick lens
%n=lens_options.index_of_refraction;
%d=lens_options.thickness;

switch 2
    case 1
        P=(n-1)*( 1/R(1) - (-1/R(2)) + ( (n-1)*d)/(n*R(1)*R(2)) );
    case 2
        % simplified
        P=((n-n_0)/n_0)*( 1/R(1) - (-1/R(2)) );
end
f=1/P;

Circle1=[C(1,:) R(1)];
Circle2=[C(2,:) R(2)];

% find intersection between the two, this will define the size
pts=intersectCircles(Circle1,Circle2);
C=C-repmat([pts(1,1) 0],2,1);
Circle1=[C(1,:) R(1)];
Circle2=[C(2,:) R(2)];
pts=intersectCircles(Circle1,Circle2);
if length(pts)<2
    error('Circles don''t overlap, are you making a concave lens?')
end

% find theta for both intersection points
M=[];
for index=1:2
    Theta1=cart2pol(pts(1,1)-C(index,1),pts(1,2)-C(index,2));
    Theta2=cart2pol(pts(2,1)-C(index,1),pts(2,2)-C(index,2));
    invert=0;
    
    if abs(Theta1-Theta2)>pi
        invert=1;
        Theta1=center_angle(Theta1);
        Theta2=center_angle(Theta2);
    end
    
    THETA=linspace(Theta1,Theta2,lens_options.nPoints);
    RHO=ones(1,lens_options.nPoints)*R(index);
    nPoints=length(THETA);
    Normals=zeros(nPoints,1);
    for iPoint=1:nPoints
        %Normals(iPoint)=
    end
    
    if invert==1
        switch 1
            case 1
                [X, Y]=pol2cart(THETA-pi,RHO);
                %Normals=normalizeAngle(cart2pol(X-C(index,1),Y-C(index,2)));
                Normals=(cart2pol(X-C(index,1),Y-C(index,2)));
            case 2
                Normals=THETA-pi;
        end
    else
        switch 1
            case 1
                [X, Y]=pol2cart(THETA,RHO);
                Normals=normalizeAngle(cart2pol(X-C(index,1),Y-C(index,2)))-pi;
            case 2
                Normals=THETA;
        end
    end
    
    %Normals=normalizeAngle(cart2pol(X-C(index,1),Y-C(index,2)));
    %Normals=THETA;
    
    M=cat(1,M,[X(:)+C(index,1) Y(:)+C(index,2) Normals(:) ones(lens_options.nPoints,1)*index]);
end

% Build object
lens_object=struct;
lens_object.lens_options=lens_options;
lens_object.center=mean(pts,1);
lens_object.radii=R;
lens_object.XV=M(:,1);
lens_object.YV=M(:,2);
lens_object.angle=lens_options.angle;
lens_object.Normals=M(:,3);
lens_object.intersections=pts;
lens_object.nVertices=lens_options.nPoints*2;
lens_object.index_of_refraction=lens_options.index_of_refraction;
lens_object.medium_index_of_refraction=lens_options.medium_index_of_refraction;
lens_object.thickness=lens_options.thickness;
lens_object.optical_power=P*100;
lens_object.focal_length=f;

plotIt=0;
if plotIt==1
    figure(1); clf
    hold on
    drawCircle(Circle1);
    drawCircle(Circle2);
    
    plot(M(:,1),M(:,2),'r.')
    plot(pts(:,1),pts(:,2),'c*')
    axis equal
end
