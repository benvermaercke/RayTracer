function object=create_lens_v3(varargin)
%%% 2DO 
% rotate lenses
% think about how to get aspherical lenses implemented

if nargin==0
    options=default_lens;
else
    options=varargin{1};
end

R=options.radii;
XV=[];
YV=[];
Normals=[];

center_points=[-options.thickness/2 options.thickness/2];
for iSurface=1:2
    switch 2
        case 1
            %%% Define angle of segment by using radius and height of lens
            max_angle=atan((options.height/2)/R(iSurface));
        case 2
            l1=[0 options.height/2 1 0];
            c1=[0 0 R(iSurface)];
            
            intersect_points=intersectLineCircle(l1,c1);
            max_angle=(atan((options.height/2)/(intersect_points(2,1))));
    end
   
    center=[center_points(iSurface)+R(iSurface) 0];
    THETA=linspace(max_angle,-max_angle,options.nPoints)';
    RHO=ones(length(THETA),1)*R(iSurface);

    [X,Y]=pol2cart(THETA,RHO);
    X=X-center(1);
    Y=Y-center(2);

    XV=cat(1,XV,X);
    YV=cat(1,YV,Y);
    
    Normals=cat(1,Normals,THETA-pi);
end

M=[XV YV Normals];

M(1:end/2,:)=sortrows(M(1:end/2,:),-2);
M(end/2+1:end,:)=sortrows(M(end/2+1:end,:),2);
%M(end+1,:)=M(1,:);

%%% Allow lens rotation
M(:,1:2)=rotate_points(M(:,1:2),options.spatial_location*0,options.angle);
M(:,3)=M(:,3)+options.angle;

%%% get focal length
n=options.index_of_refraction;
n_0=options.medium_index_of_refraction;
P=((n-n_0)/n_0)*( 1/R(1) - 1/R(2) );
focal_length=1/P;

%%% translation and rotations of final lens
XV=M(:,1)+options.spatial_location(1);
YV=M(:,2)+options.spatial_location(2);

% Build object
object.lens_options=options;
object.object_type=3;
object.center=options.spatial_location;
object.radii=R;
object.XV=XV;
object.YV=YV;
object.angle=options.angle;
object.Normals=M(:,3);

object.nVertices=length(XV);
object.index_of_refraction=options.index_of_refraction;
object.medium_index_of_refraction=options.medium_index_of_refraction;
object.thickness=options.thickness;
object.optical_power=P*100;
object.focal_length=focal_length;
object.line_style=options.line_style;

