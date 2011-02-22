MATLAB files used to plot, add, and average meshtal files from MCNP.
*Created by Patrick Snouffer Spring 2008
*Updated summer 2009
*Modified to allow the use of an input script instead of direct user input Fall 2010

This program reads in XYZ, cylindrical, and spherical(not tested yet) meshtal files that
are named in the format [root_name][index] (ie meshtal2).  

Files
MCNP5_script.m - MCNP5_script('s', 'type') - takes a scripts that supplies 
                 the command, file, and tally numbers so meshtally files can be 
								 read, added, averaged, multiplied, percent differenced, 
								 plotted, or written to a different file.  See the 
								 example_input.txt file for further deatils of the structure 
								 of the input file.  The commands can be run without an input 
								 script by setting type = 'command'

							Usage: with an input script
										MCNP5_script('input_script_name','file')
												-where the input script has all of the commands you 
												 want to run
									  
										single command
										MCNP5_script('single_command','command')
										    -where single_command is any line that is valid in 
												 the input script

							read - reads in meshtal file and saves it either after each 
							       each file or tally (for large files that might over 
										 load matlab)

						  add - adds all the specified tallies together 

							average - averages ALL the meshtallies from from indexed
							          meshtal files (ie the first tally in all the indexed
												meshtal files will be averaged)

							multiply - multiplies ALL the specified tallies by a constant

							% diff - finds the % diff of a specified benchmark meshtal
							         and all of the other specified tallies.  This is done
											 by (other_data-bench_data)/bench_data.

							plot -  SEE PLOT BELOW 

							write - writes specified tallies to a new file in the same format 
							        MCNP5 writes meshtallies

read_tallies.m - function used for read in MCNP5_man.m.  Can be used without 
                 MCNP5_script.m with the following syntax (easily used from 
								 Matlab command line and useful when only plotting funcitons of 
								 this program are needed)

								 read_tallies(inFile, numFile, saveByFile, startF) where
								        inFile - is a string of the root_name of teh file
												numFile - is the number of indexed files to be read
												saveByFile - if equals 1 then all tallies in each file
												             will be saved in a file
												startF - is the starting index of the files

												ie if there is a meshtal file named meshtal1, then in 
												Matlab the command would be 
												    read_tallies('meshtal',1,1,1)
												with all the tallies in meshtal1 being read in and 
												saved in one file

Plotting:

The other directories are class definitions.  The super class is 
CoordinateSystem.m with functions that MCNP5_man.m uses.  The other
three class are there to preform the plotting functions of each 
coordinate system.  Every user will need different types of plots
so the plotting functions can be modified or new plotting functions
can be added.  

NOTE: The obj object is the object that gets stored after reading in a meshtal
      file.  Before using the plot functions open up this file.  You will see 
			an object called tally in the varible window.  Use this object in the 
			call to the plotting function.  If the tallies were saved after each 
			file, then use tally[i] for obj where "i" is the position the desired
			tally is found in the meshtal file.  these functions can then just be 
			run from the Matlab command line.

NOTE: The energy variable for each function can be left blank or set to 0
      if the meshtally was not binned in energy.

NOTE:  All constant values are those values that the meshtal has data for
       not the values that are on the edge of the mesh cells

XYZ 
  plotXSlice(obj, Xconst, energy) - where obj is the XYZCoorSys object 
   
  plotYSlice(obj, Yconst, energy) - where obj is the XYZCoorSys object
  
  plotZSlice(obj, Zconst, energy) - where obj is the XYZCoorSys object

Cylindrical
  plotThZSlice(obj, theta, height, energy) - plots r vs phi for constatnd 
	                  theta and zwhere obj is the CylCoorSys object
	                  theta is in revolutions and needs to between 0 and 0.5 (it
										will be rotated to give -r to r)
	
	plotZSlice(obj, height, energy) - where obj is the CylCoorSys object 

	plotThSlice(obj, theta, energy) - where obj is the CycCoorSys object, and
	                  theta is the in revolutions and needs to between 0 and 
										0.5 (it will be rotated to give -r to r)


****This is the old version of how the program ran.  It is easier to use the 
    MCNP5_script.m										

MCNP5_man.m - promts user with a menu asking whether the user wants to 
              read, add, average, multiply, find the percent difference,
							plot, or write a tally to a different file

							read - reads in meshtal file and saves it either after each 
							       tally (for large files that might over load matlab) 
										 or each file

						  add - adds all the specified tallies together from a single 
							      meshtal file

							average - averages ALL the meshtallies from from indexed
							          meshtal files (ie the first tally in all the indexed
												meshtal files will be averaged)

							multiply - multiplies ALL the tallies in a file by a constant

							% diff - finds the % diff of a specified benchmark meshtal
							         and all of the other specified tallies.  This is done
											 by (other_data-bench_data)/bench_data.

							plot - currently not supported in this script. SEE BELOW to plot

							write - writes specified tallies to a new file


