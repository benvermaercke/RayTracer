function lens_object=create_lens(varargin)

if nargin==0
    lens_options=default_lens;
else
    lens_options=varargin{1};
end

% define two circles that will make up the edges of the lens
R=[lens_options.thickness lens_options.thickness]/lens_options.lens_strength;
L=sum(R)-lens_options.thickness;

if L<10
    error('Combination of radii and thickness gives improper results')
end

C=[-L*cos(lens_options.angle) -L*sin(lens_options.angle); L*cos(lens_options.angle) L*sin(lens_options.angle)]/2;
C=C+repmat(lens_options.spatial_location,2,1);

%%% Get focal length using lensmakers equation for thick lens
n=lens_options.index_of_refraction;
d=lens_options.thickness;

switch 2
    case 1
        P=(n-1)*( 1/R(1) - (-1/R(2)) + ((n-1)*d)/(n*R(1)*R(2)) );
    case 2
        % simplified
        P=(n-1)*( 1/R(1) - (-1/R(2)) );
end
f=1/P;

Circle1=[C(1,:) R(1)];
Circle2=[C(2,:) R(2)];

% find intersection between the two, this will define the size
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
    
    RHO=ones(1,lens_options.nPoints)*R(index);
    THETA=linspace(Theta1,Theta2,lens_options.nPoints);
    if invert==1
        [X, Y]=pol2cart(THETA-pi,RHO);
    else
        [X, Y]=pol2cart(THETA,RHO);
    end
    
    Normals=normalizeAngle(cart2pol(X-C(index,1),Y-C(index,2)));
    %Normals=THETA;
    
    M=cat(1,M,[X(:)+C(index,1) Y(:)+C(index,2) Normals(:) ones(lens_options.nPoints,1)*index]);
end

% Build object
lens_object=struct;
lens_object.lens_options=lens_options;
lens_object.Circle1=Circle1;
lens_object.Circle2=Circle2;
lens_object.center=mean(M,1);
lens_object.XV=M(:,1);
lens_object.YV=M(:,2);
lens_object.angle=lens_options.angle;
lens_object.Normals=M(:,3);
lens_object.intersections=pts;
lens_object.nVertices=lens_options.nPoints*2;
lens_object.index_of_refraction=lens_options.index_of_refraction;
lens_object.thickness=lens_options.thickness;
lens_object.power=P;
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
