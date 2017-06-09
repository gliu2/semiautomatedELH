# semiautomatedELH
Semi-automated detection of endolymphatic hydrops.

This is the MATLAB code for automated measurement of Reissner's membrane displacement in a pre-cropped OCT image of the mouse cochlea. 

The input image to be analyzed should show (1) the scala media centered, (2) Reissner’s membrane to the left of the scala media, and (3) the cochlea oriented as shown in Fig. 1c-d of the manuscript. Before analysis, the original OCT image usually needs to be manually cropped to the scala media (Fig. 2). Including the manual cropping step, the entire process is semi-automated.

To use, run “analyzeOCTslice_one.m” (the main script). Select the TIF image to be analyzed in the dialog box that pops up. The autodetected displacement of Reissner’s membrane is returned as the value ‘D’. If the image cannot be analyzed, the output value is ‘D=NaN’.

Before running, make sure that all MATLAB files are in the same directory. The default setting is for figures to pop up showing the intermediate steps during image processing. To turn figures off, set "TURNONFIGURES = false;" in line 13 of “analyzeOCTslice.m”.

Please let me know if there are any bugs or questions. My email is gsliu11@gmail.com. 
