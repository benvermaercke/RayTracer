function object=create_lens_v4(varargin)
%%% 2DO 


if nargin==0
    options=default_lens;
else
    options=varargin{1};
end

R=options.radii;

XV=[];
YV=[];
Normals=[];

X=linspace(-options.height/2,options.height/2,options.nPoints); % this implements the height feature
for iSurface=1:2
    Y=X.^2 ./ (R(iSurface) * (1 + sqrt(1-(1+options.kappa)*X.^2/R(iSurface)^2) ) ) ;
    if options.kappa~=0&&R(iSurface)<1000&&isfield(options,'coeffs')
        nCoeff=length(options.coeffs);
        coeff_matrix=zeros(nCoeff,options.nPoints);
        for iCoeff=1:nCoeff
            coeff_matrix(iCoeff,:)=options.coeffs(iCoeff)*X.^iCoeff;
        end
        Y=Y+sum(coeff_matrix);
    end
    Y=Y(:);
    
    %%% Define ratio to maintain focal point at specified spatial location
    ratio=abs(R(1)/sum(abs(R)));
    if iSurface==1
        Y=Y-options.thickness*(1-ratio);
    else
        Y=Y+options.thickness*ratio;
        X=-X;
    end
    Y=Y(:)';
    
    % get normals
    normals=zeros(options.nPoints,1);
    for iPoint=2:options.nPoints-1
        neighbors=[-X([iPoint-1 iPoint+1]) ;  Y([iPoint-1 iPoint+1])];
        % use neighbor to estimate normal
        alpha=calc_heading(neighbors(:));
        normals(iPoint)=alpha-pi;
    end
    normals(1)=normals(2);
    normals(end)=normals(end-1);
    
    XV=cat(1,XV,Y(:));
    YV=cat(1,YV,X(:));
    Normals=cat(1,Normals,normals);
end
XV(end+1)=XV(1);
YV(end+1)=YV(1);
Normals(end+1)=Normals(1);

M=[XV YV Normals];

%M(1:end/2,:)=sortrows(M(1:end/2,:),-2);
%M(end/2+1:end,:)=sortrows(M(end/2+1:end,:),2);
%M(end+1,:)=M(1,:);

%%% Allow lens rotation
M(:,1:2)=rotate_points(M(:,1:2),options.spatial_location*0,options.angle);
M(:,3)=M(:,3)+options.angle;

%%% get focal length
R=options.radii;
n=options.index_of_refraction;
n_0=1;%options.medium_index_of_refraction;
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

