clear all
clc

addpath(genpath(fileparts(mfilename('fullpath'))))

RT=RayTracer();

RT.add_lens('radii',[50 -50],'spatial_location',[0 0],'height',25.4*1,'thickness',5)
RT.add_lens('radii',[100 -100],'spatial_location',[150 0],'height',25.4*2,'thickness',7)

RT.add_mirror('height',40,'spatial_location',[-50 0],'angle',pi/4*3-.02)

RT.add_absorber('height',100,'spatial_location',[250 0])

RT.add_bundle('bundle_type',2,'nRays',5,'center_location',[-50 -50],'initial_direction',pi/2)

%%
RT.draw_space()

%%
RT.run_simulation()

%%
RT.update_space()







