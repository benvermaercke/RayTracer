clear all
clc

addpath(genpath(fileparts(mfilename('fullpath'))))

RT=RayTracer();

RT.add_lens('radii',[50 -50],'spatial_location',[0 0],'height',25.4*1,'thickness',4)
RT.add_lens('radii',[100 -100],'spatial_location',[150 0],'height',25.4*1.7,'thickness',5)

RT.add_absorber('height',100,'spatial_location',[250 0])

RT.add_bundle('bundle_type',1,'nRays',10,'center_location',[-50 0],'initial_direction',0,'angle_spread',.6)
RT.add_bundle('bundle_type',1,'nRays',10,'center_location',[-50 5],'initial_direction',0,'angle_spread',.6,'color',[0 0 1])

%%
RT.draw_space()

%%
RT.run_simulation()

%%
RT.update_space()







