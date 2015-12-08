clear all
clc

addpath(genpath(fileparts(mfilename('fullpath'))))

RT=RayTracer('x_range',[-200 200],'y_range',[-100 100]);

RT.add_lens('radii',[25 -25],'spatial_location',[125 0],'height',25.4*1,'thickness',6,'angle',pi)
RT.add_lens('radii',[75 -75],'spatial_location',[50 0],'height',25.4*1,'thickness',4,'angle',pi)

%RT.add_mirror('spatial_location',[0 0],'height',25.4*2,'thickness',2,'angle',pi/4*3)

RT.add_lens('radii',[40 -40],'spatial_location',[0 -50],'height',25.4*2,'thickness',20,'angle',pi/2)

RT.add_lens('radii',[40 -40],'spatial_location',[0 50],'height',25.4*2,'thickness',20,'angle',pi/2)


%RT.add_absorber('height',100,'spatial_location',[0 -90],'angle',pi/2)
RT.add_absorber('height',100,'spatial_location',[0 90],'angle',pi/2)

%RT.add_bundle('bundle_type',1,'nRays',3,'center_location',[150 0],'initial_direction',pi,'angle_spread',.6)
%RT.add_bundle('bundle_type',2,'nRays',3,'center_location',[175 0],'initial_direction',pi,'beam_spread',6,'color',[0 0 1])
RT.add_bundle('bundle_type',1,'nRays',8,'center_location',[0 -90],'initial_direction',pi/2,'angle_spread',.9,'color',[0 .7 0])

%%%
RT.draw_space()

%%
RT.run_simulation()

%%
RT.update_space()







