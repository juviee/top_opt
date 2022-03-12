## How to launch:
Use plot_diff_angles.m script to launch calculations for isotropic material, 
anisotropic material with laying angles 0, 22.5, 45, 90

Please, before launch, **create folders apdl_const and pics_const**. This will be fixed later

Results are contained in:
+ Density maps and evolution animations in pics_const folder
+ APDL scripts in apdl_const folder
+ Max displacements in u_matlab.txt

## Todo:
0) Investigate diff between ANSYS solution and Matlab solution
	+ Implement color mapping of displacements in Matlab solution( check for fea_plain_mbb_1.m)
1) Research dependence of max displacement from laying angle
	+ Add another calculating scheme that is not symmetric
2) Implement General Optimality Criteria Solver
	+ Check if it works. Otherwise move to another solver schemes(MMA)
	+ Check homogenization approach
3) Implement optimization by laying angle
4) Implement optimization by fiber density