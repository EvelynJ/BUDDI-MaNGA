# BUDDI-MaNGA

This repository contains the IDL files for BUDDI-MaNGA, uploaded here for backup purposes.

Guide to the key codes:

**buddi_manga_new.pro**: this is the code to run BUDDI on all MaNGA galaxies

**buddi_manga_catalog.pro**: run this code to create the final output catalog with the fit information. Can be run at any time, but will always create a new extension in the fits file. 



Other codes that are called within these codes:

**buddi_manga_prep.pro**: code to prepare the MaNGA datacube (convert flux to Jy, create bad pixel mask etc)

**clean_buddi_manga.pro**: code to run through all the buddi_manga directories and clean the images we no longer need and can recreate

**create_buddi_start_file.pro**: code to create the buddi start files for the fits 

**psf_manga.pro**: code to create the MaNGA PSF datacube, using the griz-band psf images in the fits extensions and interpolating for wavelength


