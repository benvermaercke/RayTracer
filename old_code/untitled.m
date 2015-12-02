clear all
clf
clc

F1=50;
correction_factor=1;
Object_counter=1;
lens_options=default_lens;
lens_options.radii=[F1 -F1]*correction_factor;
lens_options.thickness=4*2;
lens_options.height=25.4*1.5;
lens_options.spatial_location=[-F1 0];
lens_options.nPoints=1000;
Objects{Object_counter}=create_lens_v3(lens_options);Object_counter=Object_counter+1;

lens_options=default_lens;
lens_options.radii=[F1 -F1]*correction_factor;
lens_options.thickness=4*2;
lens_options.height=25.4*1.5;
lens_options.spatial_location=[-F1 0];
lens_options.nPoints=1000;
Objects{Object_counter}=create_lens_v4(lens_options);Object_counter=Object_counter+1;

plot([Objects{1}.Normals Objects{2}.Normals])