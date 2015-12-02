function object=create_lens_v2(varargin)
%%% 2DO 
% create all sorts of lenses based on front and back curvature and
%   thickness, distance between center points
%   height will clip the lens
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

for iSurface=1:2
    %%% Define angle of segment by using radius and height of lens
    max_angle=atan((options.height/2)/R(iSurface));
    
    if sign(R(iSurface))>0
        center=[R(iSurface)-options.thickness/2 0];
        THETA=linspace(-max_angle,max_angle,options.nPoints)';
    else
        center=[R(iSurface)+options.thickness/2 0];
        THETA=linspace(max_angle,-max_angle,options.nPoints)';
    end
    RHO=ones(length(THETA),1)*R(iSurface);

    [X,Y]=pol2cart(THETA,RHO);
    X=X-center(1);
    Y=Y-center(2);
    XV=cat(1,XV,X);
    YV=cat(1,YV,Y);
    Normals=cat(1,Normals,THETA-pi);
end

XV(end+1)=XV(1);
YV(end+1)=YV(1);

%%% get focal length
n=options.index_of_refraction;
n_0=options.medium_index_of_refraction;
P=((n-n_0)/n_0)*( 1/R(1) - 1/R(2) );
focal_length=1/P;

%%% translation and rotations of final lens
XV=XV+options.spatial_location(1);
YV=YV+options.spatial_location(2);

% Build object
object.lens_options=options;
object.object_type=3;
object.center=options.spatial_location;
object.radii=R;
object.XV=XV;
object.YV=YV;
object.angle=options.angle;
object.Normals=Normals;

object.nVertices=length(XV);
object.index_of_refraction=options.index_of_refraction;
object.medium_index_of_refraction=options.medium_index_of_refraction;
object.thickness=options.thickness;
object.optical_power=P*100;
object.focal_length=focal_length;
object.line_style=options.line_style;

