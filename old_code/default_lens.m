function options=default_lens(varargin)

%%% These 3 properties define optical power and shape of lens
options.radii=[50 -50]; % mm
options.thickness=5; % mm
options.height=25.4; % mm =SM01
options.kappa=0; % default to spherical lens

options.spatial_location=[0 0]; % mm
options.angle=0; % rotation in radians
options.nPoints=51;
options.index_of_refraction=1.517; % glass
options.medium_index_of_refraction=1.00029; % air
options.focal_length=50;
options.line_style='g.-';