clear all
clc

addpath(genpath(fileparts(mfilename('fullpath'))))

RT=RayTracer();

RT.add_absorber('height',300,'spatial_location',[200 0])

kappa_val=-3.5;

switch 4
    case 1 % show how outer rays for focii at different distance from lens => blurry image
        RT.add_lens('radii',[20 -20],'spatial_location',[0 0],'height',25.4*1,'thickness',10,'kappa',1)
        
        RT.add_bundle('bundle_type',2,'nRays',11,'center_location',[-50 0],'initial_direction',0,'beam_spread',15,'color',[0 0 1])
        RT.add_bundle('bundle_type',2,'nRays',11,'center_location',[-50 0],'initial_direction',0,'beam_spread',10,'color',[0 1 1])
        RT.add_bundle('bundle_type',2,'nRays',11,'center_location',[-50 0],'initial_direction',0,'beam_spread',5,'color',[1 0 0])
    case 2 % off-axis offset: effect is accentuated because more rays are away from optical axis
        RT.add_lens('radii',[20 -20],'spatial_location',[0 0],'height',25.4*1,'thickness',10,'kappa',1)
        
        RT.add_bundle('bundle_type',2,'nRays',11,'center_location',[-50 0],'initial_direction',0,'beam_spread',10,'color',[1 0 0])
        RT.add_bundle('bundle_type',2,'nRays',11,'center_location',[-50 3],'initial_direction',0,'beam_spread',10,'color',[0 0 1])
    case 3 % off-axis angle:
        RT.add_lens('radii',[20 -20],'spatial_location',[0 0],'height',25.4*1,'thickness',10,'kappa',1)
        
        RT.add_bundle('bundle_type',2,'nRays',11,'center_location',[-50 0],'initial_direction',0,'beam_spread',10,'color',[1 0 0])
        RT.add_bundle('bundle_type',2,'nRays',11,'center_location',[-50 -1.7],'initial_direction',2/180*pi,'beam_spread',10,'color',[0 1 1])
    case 4 % misalignment between lens and coverslip
        % 2DO: need object specific IOR values!!!! so we can simulate
        % transitions from water to glass to tissue etc.
        RT.y_range=[-300 300];
        lens_thickness=6;
        lens_height=25.4*1.25;
        focal_length=50;
        
        window_thickness=30;
        Y_offset=-50;
        
        RT.add_lens('radii',[focal_length -focal_length],'spatial_location',[0 -Y_offset],'height',lens_height,'thickness',lens_thickness,'kappa',kappa_val)
        
        RT.add_bundle('bundle_type',2,'nRays',21,'center_location',[-50 -Y_offset],'initial_direction',0,'beam_spread',30,'color',[1 0 0])
        
        % adding the block parallel to the objective causes the focus
        % length to increase
        RT.add_lens('radii',[focal_length -focal_length],'spatial_location',[0 0],'height',lens_height,'thickness',lens_thickness,'kappa',kappa_val)        
        RT.add_lens('radii',[10000 -10000],'spatial_location',[30 0],'height',50,'thickness',window_thickness,'kappa',0,'angle',0/180*pi,'line_style','k-')
        
        RT.add_bundle('bundle_type',2,'nRays',21,'center_location',[-50 0],'initial_direction',0,'beam_spread',30,'color',[1 0 0])
        
        % in this path, we tilted the block to represent misalign coverslip
        % relative to the objective : the focus show a banana-like
        % deformation
        RT.add_lens('radii',[focal_length -focal_length],'spatial_location',[0 Y_offset],'height',lens_height,'thickness',lens_thickness,'kappa',kappa_val)        
        RT.add_lens('radii',[10000 -10000],'spatial_location',[30 Y_offset],'height',50,'thickness',window_thickness,'kappa',0,'angle',10/180*pi,'line_style','')
        
        RT.add_bundle('bundle_type',2,'nRays',21,'center_location',[-50 Y_offset],'initial_direction',0,'beam_spread',30,'color',[0 0 1])
        
    case 5 % comparison of spherical and aspherical lenses
        RT.y_range=[-300 300];
        lens_thickness=6;
        lens_height=25.4*1.25;
        focal_length=50;
        Y_offset=-35;
        
                
        RT.add_lens('radii',[focal_length -focal_length],'spatial_location',[0 -Y_offset],'height',lens_height,'thickness',lens_thickness,'kappa',0)        
        RT.add_bundle('bundle_type',2,'nRays',9,'center_location',[-50 -Y_offset],'initial_direction',0,'beam_spread',30,'color',[1 0 0])
        
        RT.add_lens('radii',[focal_length -focal_length],'spatial_location',[0 Y_offset],'height',lens_height,'thickness',lens_thickness,'kappa',kappa_val)
        RT.add_bundle('bundle_type',2,'nRays',9,'center_location',[-50 Y_offset],'initial_direction',0,'beam_spread',30,'color',[0 0 1])
        
end
%%
RT.draw_space()

%%
RT.run_simulation()

%%
RT.update_space()

plot([focal_length focal_length],[-300 300],'m-')

%% expand Y axis
cur_range=get(gca,'yLim');
set(gca,'yLim',cur_range/3)
axis square






