function object=create_mirror(varargin)

if nargin==0
    options=default_lens;
else
    options=varargin{1};
end

Y_points=linspace(options.spatial_location(2)-options.height/2,options.spatial_location(2)+options.height/2,options.nPoints);
[X, Y]=meshgrid([options.spatial_location(1)-options.thickness/2 options.spatial_location(1)+options.thickness/2],Y_points);

M=[X(:) Y(:)];
M(end/2+1:end,:)=flipud(M(end/2+1:end,:));
M(end+1,:)=M(1,:);

M=rotate_points(M,options.spatial_location,options.angle);
%%% add small offset to move center of gravity to mirror surface
offset=[cos(options.angle) sin(options.angle)]*options.thickness/2;
M=M+repmat(offset,size(M,1),1);

% Construct object
object.mirror_options=options;
object.object_type=2;
object.center=options.spatial_location;
object.XV=M(:,1);
object.YV=M(:,2);
object.angle=options.angle;
object.normal=normalizeAngle(options.angle+pi/2);
object.line_style=options.line_style;


