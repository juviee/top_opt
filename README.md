## How to launch:
Use plot_diff_angles.m script to launch calculations for isotropic material, 
anisotropic material with laying angles 0, 22.5, 45, 90

~~Please, before launch, create folders apdl_const and pics_const. This will be fixed later~~

Results are contained in:
+ Density maps in pics_const folder
+ APDL scripts in apdl_const folder
+ Structure evolution animations in gifs_const folder
+ Max displacements in u_matlab.txt
+ FEA maps with min-max value text files in maps_const

## Todo:

~~Fix directories creation~~

0) ~~Investigate diff between ANSYS solution and Matlab solution~~

	+ ~~Implement color mapping of displacements in Matlab solution( check for fea_plain_mbb_1.m)~~

	+ ~~Fix Mises stress maps~~
1) Research dependence of max displacement from laying angle
	+ Add another calculating scheme that is not symmetric
2) Implement General Optimality Criteria Solver
	+ Check if it works. Otherwise move to another solver schemes(MMA)
	+ Check homogenization approach
3) Implement optimization by laying angle
4) Implement optimization by fiber density

5) ~~Implement settings parsing to decrease function args~~

## Changelog:
14/04/2022
+ Implemented settings file parsing
+ Reworked API towards decreasing function args

13/04/2022
+ Implemented other stress maps, fixed stress mises maps
+ Fixed size bug in top_comp.m

12/04/2022
+ Fixed directories trouble
+ Implemented translation maps
+ Implemented stress maps, but needs fixes
