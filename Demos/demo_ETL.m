clear all
clc

F1=50;
F2=100;
F3=150;

for distance=[25 50 100]
    figure(distance)
    
    addpath(genpath(fileparts(mfilename('fullpath'))))
    
    RT=RayTracer('y_range',[-100 100]);
    
    RT.add_absorber('height',150,'spatial_location',[250 0])
    
    % ETL state 1
    RT.add_lens('radii',[F1 -F1],'spatial_location',[0 40],'height',25.4*1.3,'thickness',7,'line_style','c.-')
    RT.add_lens('radii',[-100 inf],'spatial_location',[distance 40],'height',25.4*1.5,'thickness',5)
    
    % ETL state 2
    RT.add_lens('radii',[F2 -F2],'spatial_location',[0 0],'height',25.4*1.5,'thickness',5,'line_style','b.-')
    RT.add_lens('radii',[-100 inf],'spatial_location',[distance 0],'height',25.4*1.5,'thickness',5)
    
    % ETL state 2
    RT.add_lens('radii',[F3 -F3],'spatial_location',[0 -40],'height',25.4*1.7,'thickness',4,'line_style','k.-')
    RT.add_lens('radii',[-100 inf],'spatial_location',[distance -40],'height',25.4*1.5,'thickness',5)
    
    
    % Beam 1
    RT.add_bundle('bundle_type',2,'nRays',5,'center_location',[-50 40],'initial_direction',0,'angle_spread',.6)
    
    % Beam 2
    RT.add_bundle('bundle_type',2,'nRays',5,'center_location',[-50 0],'initial_direction',0,'angle_spread',.6)
    
    % Beam 3
    RT.add_bundle('bundle_type',2,'nRays',5,'center_location',[-50 -40],'initial_direction',0,'angle_spread',.6)
    
    
    
    
    %%
    RT.draw_space()
    
    %%
    RT.run_simulation()
    
    %%
    RT.update_space()
    
    
end

if 0
    %%
    figure(1)
    distance=200
    RT=RayTracer('y_range',[-100 100]);
    RT.add_lens('radii',[F1 -F1],'spatial_location',[0 0],'height',25.4*1.3,'thickness',7,'line_style','c.-')
    RT.add_lens('radii',[-100 inf],'spatial_location',[distance 0],'height',25.4*1.5,'thickness',5)
    RT.add_bundle('bundle_type',2,'nRays',5,'center_location',[-50 0],'initial_direction',0,'angle_spread',.6)
    %%%
    RT.draw_space()
    RT.run_simulation()
    RT.update_space()
end
