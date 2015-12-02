function varargout=lens_simulation(varargin)
% Create lenses, mirrors and absorbers in 2D space,
% give them properties and orientations
% create of bundle of rays
% for each of them, walk the path until they reach an absorber, reflect and
% refract where needed.

IOR_air=1.00029;

% A lens will have polygon coords in 2D space and an index of refraction
% Scan lens
lens_options=default_lens;

lens_options.lens_strength=.35;%.35;
%lens_options.height=150; % 50
lens_options.thickness=20;
lens_options.angle=0;
% need thickness and focal length

lens_options.spatial_location=[-70 0];
lens_options.spatial_location=[-55.2639 0];
lens_options.nPoints=101;
Lens_01=create_lens(lens_options);


%[Lens_01.center(1)+Lens_01.focal_length*cos(Lens_01.angle) Lens_01.center(2)+Lens_01.focal_length*sin(Lens_01.angle)]

if 0
    %%
    
    %lens_options.lens_strength=.1;%.35;
    %lens_options.height=125;
    
    % height =50
    X=.10:.05:.35;
    Y=[131.2 84.52 60.51 43.39 28.69 17.08];
    plot(X,Y)
    
    % .35 : 17.08
    % .30 : 28.69
    % .25 : 43.39
    % .20 : 60.51
    % .15 : 84.52
    % .10 : 131.2
    
    
    switch lens_options.lens_strength
        case .1 % 2.6348   -2.2845
            % strength .1
            X=[50 70 100 150];
            Y=70+[51.4864  125.4393 185.8854 217.6759];
        case .2 %  2.7390   -4.8252
            % strength .2
            X=[50 70 100];
            Y=70+[60.51  119.6000 198];
        case .3 % 2.3005  -83.5772
            X=[50 75 100 125];
            Y=70+[-42.0305 23.4864 77.8701 131.5530];
        case .5 % 1.7552  -85.1719
            X=[75 100 125];
            Y=70+[-24.2099 21.7053 63.5503];
        case 1 %  1.2451  -99.6472
            X=[ 100 125 150 200];
            Y=70+[-52.7141 -8.9581 24.7021 74.3223];
    end
    
    [xFit,yFit,coeffs]=dataFitting(X,Y,'pow');
    
    % focal length relates
    % linear positive to height
    % square negative to strength/curvature
    
    %focal_length=50/.2^2
    %focal_length=lens_options.height/lens_options.lens_strength^2
    
    clf
    plot(X,Y,'ko')
    hold on
    plot(xFit,yFit,'r-')
    hold off
    title(coeffs)
    coeffs
    die
    
end
%%

% Tube lens
lens_options=default_lens;
lens_options.lens_strength=.38;
%lens_options.height=100;
lens_options.thickness=40;
lens_options.spatial_location=[110 0];
lens_options.spatial_location=[101.8019 0];
lens_options.nPoints=101;
Lens_02=create_lens(lens_options)

%%% A mirror will have rect polygon coords in 2D space and reflection proportion
% Scan mirror 01
mirror_options=default_mirror;
mirror_options.height=40;
%mirror_options.angle=-pi/4;%+rand*.03-.015;
mirror_options.angle=pi/4*3;%+rand*.03-.015;
mirror_options.spatial_location=[-150 -50];
Scan_Mirror_01=create_mirror(mirror_options);

% Scan mirror 02
mirror_options=default_mirror;
mirror_options.height=40;
%mirror_options.angle=-pi/4;%+rand*.03-.015;
mirror_options.angle=-pi/4;%+rand*.03-.015;
mirror_options.spatial_location=[-150 0];
Scan_Mirror_02=create_mirror(mirror_options);

%%% Final elliptical mirror => to objective
mirror_options=default_mirror;
mirror_options.height=150;
mirror_options.spatial_location=[300 0];
mirror_options.angle=pi/4;
Mirror_02=create_mirror(mirror_options);

% An absorber will have rect polygon coords in 2D space and stops the rays
absorber_options=default_absorber;
absorber_options.height=300;
absorber_options.spatial_location=[400 -100];
absorber_options.nPoints=20;
Absorber_01=create_absorber(absorber_options);

absorber_options=default_absorber;
absorber_options.spatial_location=[300 -200];
absorber_options.height=200;
absorber_options.nPoints=20;
absorber_options.angle=pi/2;
Absorber_02=create_absorber(absorber_options);

% start a ray at some given position and start moving in the given
% direction until we reach and object to interact with

figure(1);clf
hold on
plot([-300 450],[0 0],'k-')

plot(Scan_Mirror_01.center(1),Scan_Mirror_01.center(2),'m+')
plot(Scan_Mirror_02.center(1),Scan_Mirror_02.center(2),'m+')
plot(Scan_Mirror_01.XV,Scan_Mirror_01.YV,'c.-')
plot(Scan_Mirror_02.XV,Scan_Mirror_02.YV,'c.-')

plot(Lens_01.center(1),Lens_01.center(2),'k+')
plot([Lens_01.center(1) Lens_01.center(1)+Lens_01.focal_length*cos(Lens_01.angle)],[Lens_01.center(2) Lens_01.center(2)+Lens_01.focal_length*sin(Lens_01.angle)],'ko-')
plot([Lens_01.center(1) Lens_01.center(1)-Lens_01.focal_length*cos(Lens_01.angle)],[Lens_01.center(2) Lens_01.center(2)-Lens_01.focal_length*sin(Lens_01.angle)],'ko-')
plot(Lens_01.XV,Lens_01.YV,'g-')

plot(Lens_02.center(1),Lens_02.center(2),'k+')
plot([Lens_02.center(1) Lens_02.center(1)+Lens_02.focal_length*cos(Lens_01.angle)],[Lens_02.center(2) Lens_02.center(2)+Lens_02.focal_length*sin(Lens_02.angle)],'ks-')
plot([Lens_02.center(1) Lens_02.center(1)-Lens_02.focal_length*cos(Lens_01.angle)],[Lens_02.center(2) Lens_02.center(2)-Lens_02.focal_length*sin(Lens_02.angle)],'ks-')
plot(Lens_02.XV,Lens_02.YV,'g-')

plot(Mirror_02.XV,Mirror_02.YV,'c.-')
plot(Absorber_01.XV,Absorber_01.YV,'k.')
plot(Absorber_02.XV,Absorber_02.YV,'k.')
axis equal
box off
drawnow



step_size=.1;

initial_direction=0;

switch 4
    case 0
        nRays=1;
        next_position=[-20 10];
        cur_angle=initial_direction;
        %in_air=1;
        %tracing=1;
    case 1
        nRays=1;
        next_position=[20 10];
        cur_angle=initial_direction-pi;
        %in_air=1;
        %tracing=1;
    case 2 % start from origin
        nRays=5;
        
        next_position=repmat([-150 0],nRays,1);
        cur_angle=linspace(initial_direction-pi/10,initial_direction+pi/10,nRays)';
        %in_air=ones(nRays,1);
        %tracing=ones(nRays,1);
    case 3 % parallel beam
        nRays=10;
        initial_direction=pi/2;
        
        center_location=[-150 -50];
        next_position=[center_location(1)+linspace(-2,2,nRays)' center_location(2)+zeros(nRays,1)];
        cur_angle=ones(nRays,1)*initial_direction;
        
    case 4 % parallel beam horizontal
        nRays=3;
        initial_direction=0;
        
        center_location=[-250 -50];
        horizontal_spread=[0 0];
        vertical_spread=[-2 2]*5;
        
        next_position=[center_location(1)+linspace(horizontal_spread(1),horizontal_spread(2),nRays)' center_location(2)+linspace(vertical_spread(1),vertical_spread(2),nRays)'];
        cur_angle=ones(nRays,1)*initial_direction;
end

in_air=ones(nRays,1);
tracing=ones(nRays,1);
in_object=zeros(nRays,1);

Rays.nRays=nRays;
Rays.next_position=next_position;
Rays.cur_angle=cur_angle;
Rays.in_air=in_air;
Rays.in_lens=0;
Rays.tracing=tracing;
Rays.in_object=in_object;
Rays.step_size=step_size;

M_all=[];
for iRay=1:Rays.nRays
    M=[];
    step_nr=0;
    while Rays.tracing(iRay)==1
        % Advance ray one step in direction of ray
        next_position_temp=advance_rays(Rays,iRay);
        
        %%% out of simulation region => destroy
        max_dist_vector=[-250 400 ; -300 100];
        if ~inpolygon(next_position_temp(1),next_position_temp(2),max_dist_vector(1,:),max_dist_vector(2,:))
            Rays.tracing(iRay)=0;
            break
        end
        
        %%% Check for absorber crossing => destroy
        if inpolygon(next_position_temp(1),next_position_temp(2),Absorber_01.XV,Absorber_01.YV)
            Rays.tracing(iRay)=0;
            break
        end
        if inpolygon(next_position_temp(1),next_position_temp(2),Absorber_02.XV,Absorber_02.YV)
            Rays.tracing(iRay)=0;
            break
        end
        
        %%% Check for mirror crossing => reflect
        if inpolygon(next_position_temp(1),next_position_temp(2),Scan_Mirror_01.XV,Scan_Mirror_01.YV)
            Rays.cur_angle(iRay)=(Scan_Mirror_01.normal)-((Rays.cur_angle(iRay))-(Scan_Mirror_01.normal));
        end
        
        if inpolygon(next_position_temp(1),next_position_temp(2),Scan_Mirror_02.XV,Scan_Mirror_02.YV)
            Rays.cur_angle(iRay)=(Scan_Mirror_02.normal)-((Rays.cur_angle(iRay))-(Scan_Mirror_02.normal));
        end
        
        if inpolygon(next_position_temp(1),next_position_temp(2),Mirror_02.XV,Mirror_02.YV)
            Rays.cur_angle(iRay)=(Mirror_02.normal)-((Rays.cur_angle(iRay))-(Mirror_02.normal));
        end
        
        %%% Check for lens crossing => refract
        if inpolygon(next_position_temp(1),next_position_temp(2),Lens_01.XV,Lens_01.YV)
            if Rays.in_object(iRay)==0 % transition air to object
                Rays.in_object(iRay)=1;
                %Rays.in_lens(iRay)=1;
                [min_dist, loc]=min(calc_dist_matrix([Rays.next_position((iRay),1),Rays.next_position((iRay),2)],[Lens_01.XV,Lens_01.YV]));
                angle_normal=Lens_01.Normals(loc);
                
                % refract angle
                Rays.cur_angle(iRay)=(angle_normal)-snells_law(IOR_air,Lens_01.index_of_refraction,(Rays.cur_angle(iRay))-(angle_normal))-pi;
                %drawLine(createLine([next_position cos(Lens_01.Normals(loc)) sin(Lens_01.Normals(loc))]))
            end
        elseif inpolygon(next_position_temp(1),next_position_temp(2),Lens_02.XV,Lens_02.YV)
            if Rays.in_object(iRay)==0 % transition air to object
                Rays.in_object(iRay)=2;
                %Rays.in_lens(iRay)=2;
                [min_dist, loc]=min(calc_dist_matrix([Rays.next_position((iRay),1),Rays.next_position((iRay),2)],[Lens_02.XV,Lens_02.YV]));
                angle_normal=Lens_02.Normals(loc);
                Rays.cur_angle(iRay)=(angle_normal)-snells_law(IOR_air,Lens_02.index_of_refraction,(Rays.cur_angle(iRay))-(angle_normal))-pi;
            end
            
        else % not in any object 
            if Rays.in_object(iRay)==1 % transition object to air
                Rays.in_object(iRay)=0;
                %Rays.in_lens(iRay)=0;
                [min_dist, loc]=min(calc_dist_matrix([Rays.next_position(iRay,1),Rays.next_position(iRay,2)],[Lens_01.XV,Lens_01.YV]));
                angle_normal=Lens_01.Normals(loc);
                
                % refract angle
                Rays.cur_angle(iRay)=(angle_normal)+snells_law(Lens_01.index_of_refraction,IOR_air,(Rays.cur_angle(iRay))-(angle_normal));
                %drawLine(createLine([next_position(iRay,:) cos(Lens_01.Normals(loc)) sin(Lens_01.Normals(loc))]))
                %drawLine(createLine([Lens_01.XV(loc) Lens_01.YV(loc) cos(Lens_01.Normals(loc)) sin(Lens_01.Normals(loc))]))
            elseif Rays.in_object(iRay)==2
                Rays.in_object(iRay)=0;
                [min_dist, loc]=min(calc_dist_matrix([Rays.next_position(iRay,1),Rays.next_position(iRay,2)],[Lens_02.XV,Lens_02.YV]));
                angle_normal=Lens_02.Normals(loc);
                Rays.cur_angle(iRay)=angle_normal+snells_law(Lens_02.index_of_refraction,IOR_air,Rays.cur_angle(iRay)-angle_normal);
            end
        end
        
        
        %%% update position
        next_position(iRay,:)=next_position_temp;
        Rays.next_position=next_position;
        
        step_nr=step_nr+1;
        if step_nr>2E3
            %Rays.tracing(iRay)=0;
        end
        M(step_nr,:)=next_position(iRay,:);
    end
    M_all=cat(1,M_all,M);
end

plot(M_all(:,1),M_all(:,2),'r.','markerSize',1)

title(step_nr)
axis equal

%mean(normalizeAngle(Rays.cur_angle))/pi*180
% mean(Rays.next_position(:,2))
%std(normalizeAngle(Rays.cur_angle))

zero_crossings=M_all(diff(sign(M_all(:,2)))==-2,1);
real_F=70+zero_crossings(2);
[Lens_01.focal_length real_F Lens_01.focal_length/real_F]


%varargout{1}=M_all;

function mirror_options=default_mirror(varargin)

mirror_options.height=40;
mirror_options.thickness=5;
mirror_options.spatial_location=[0 0];
mirror_options.angle=0;
mirror_options.nPoints=15;


function mirror_object=create_mirror(varargin)

if nargin==0
    mirror_options=default_lens;
else
    mirror_options=varargin{1};
end

Y_points=linspace(mirror_options.spatial_location(2)-mirror_options.height/2,mirror_options.spatial_location(2)+mirror_options.height/2,mirror_options.nPoints);
[X, Y]=meshgrid([mirror_options.spatial_location(1)-mirror_options.thickness/2 mirror_options.spatial_location(1)+mirror_options.thickness/2],Y_points);

M=[X(:) Y(:)];

M=rotate_points(M,mirror_options.spatial_location,mirror_options.angle);
offset=[sin(mirror_options.angle) cos(mirror_options.angle)]*mirror_options.thickness/2;
M=M+repmat(offset,size(M,1),1);

% Construct object
mirror_object=struct;
mirror_object.mirror_options=mirror_options;
mirror_object.center=mirror_options.spatial_location;
mirror_object.XV=M(:,1);
mirror_object.YV=M(:,2);
mirror_object.angle=mirror_options.angle;
mirror_object.normal=normalizeAngle(mirror_options.angle+pi/2);


function absorber_options=default_absorber(varargin)

absorber_options.height=150;
absorber_options.thickness=10;
absorber_options.spatial_location=[0 0];
absorber_options.angle=0;
absorber_options.nPoints=15;


function absorber_object=create_absorber(varargin)

if nargin==0
    absorber_options=default_lens;
else
    absorber_options=varargin{1};
end

Y_points=linspace(absorber_options.spatial_location(2)-absorber_options.height/2,absorber_options.spatial_location(2)+absorber_options.height/2,absorber_options.nPoints);
[X, Y]=meshgrid([absorber_options.spatial_location(1)-absorber_options.thickness/2 absorber_options.spatial_location(1)+absorber_options.thickness/2],Y_points);

M=[X(:) Y(:)];
M=rotate_points(M,absorber_options.spatial_location,absorber_options.angle);

% Construct object
absorber_object=struct;
absorber_object.absorber_options=absorber_options;
absorber_object.XV=M(:,1);
absorber_object.YV=M(:,2);

function lens_options=default_lens(varargin)

lens_options.lens_strength=.2;
%lens_options.height=30;
lens_options.thickness=10;
lens_options.spatial_location=[0 0];
lens_options.angle=0;
lens_options.nPoints=51;
lens_options.index_of_refraction=1.517;

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

%Circle1=[C(1,:) R(1)];
%Circle2=[C(2,:) R(2)];

% find intersection between the two, this will define the size
%pts=intersectCircles(Circle1,Circle2);
%lens_height=calc_dist(pts);

% resize_factor=lens_options.height/lens_height;
% C=C*resize_factor;
C=C+repmat(lens_options.spatial_location,2,1);
% R=R*resize_factor;

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




function dist=calc_dist(pts)
x1=pts(1,1);
y1=pts(1,2);
x2=pts(2,1);
y2=pts(2,2);
dist=sqrt((x2-x1).^2+(y2-y1).^2);


function distances=calc_dist_matrix(point,M)

x0 = point(1);
y0 = point(2);
distances = sqrt((M(:,1)-x0).^2 + (M(:,2)-y0).^2);

function angle=center_angle(angle)

block_size=pi;
offset=round(angle/block_size);
angle=angle-offset*block_size;


function angle_out=snells_law(IOR_leaving,IOR_entering,angle_in)

%angle_out=(IOR_leaving*sin(angle_in)) / IOR_entering;
angle_out=asin((IOR_leaving*sin(angle_in)) / IOR_entering);


function out=rotate_points(in,center,angle)

[theta, rho]=cart2pol(in(:,1)-center(1),in(:,2)-center(2));

theta=theta+angle;

[X,Y]=pol2cart(theta,rho);

out=[X+center(1),Y+center(2)];


function out=advance_rays(Rays,iRay)

out=Rays.next_position(iRay,:)+Rays.step_size*[cos(Rays.cur_angle(iRay)) sin(Rays.cur_angle(iRay))];
