;
; Preliminary code to try to automate the running of BUDDI on all MaNGA galaxies.
; Version 0.0 :  February 2020, EJo, Santiago, Chile
; Version 1.0 :  May 2020, EJo & BHa. Added IDL bridge, then removed it as it didn't work
;
; To run in terminal:
;     .compile create_buddi_start_file
;     buddi_manga,1
; Note: the number after calling buddi_manga is the session number. This helps the 
; user to keep track of when a fit fails if they are running the code on multiple 
; terminal windows. The session number appears in the Ǵalaxies_in_progress' file, 
; so when a session fails, one can check which galaxy was the last one used for 
; that session number
;


pro BUDDI_MaNGA_new,session
 print, systime(0)
;###########################################
;set up directories for fits and results
;###########################################

root='/data2/ejohnston/BUDDI_MaNGA/'
root_files='/data2/ejohnston/BUDDI_MaNGA/static_files/'
root_fits=root+'fits/'
root_output=root+'output/'

CD, root_fits, CURRENT=old_dir

;###########################################
; * Read in a list of MaNGA galaxies
;###########################################
Manga_list=mrdfits(root_files+'dapall-v2_4_3-2.2.1.fits',1)
Pymorph_list=mrdfits(root_files+'manga-pymorph-DR15.fits',2) ;extensions 1,2,3 are g,r,i band results
Pymorph_SPA=mrdfits(root_files+'manga-pymorph-DR15-SPA.fits',1) 

;Simard_BD=mrdfits(root_files+'Simard_BDfits.fit',1)
;Simard_SS=mrdfits(root_files+'Simard_SSfits.fit',1)

Manga_RA=Manga_list.OBJRA
Manga_Dec=Manga_list.OBJDEC

;Simard_BD_RA=Simard_BD._RA
;Simard_BD_Dec=Simard_BD._DE

;avoid mismatch by rounding to 3dp
Manga_RA = Float(Round(Manga_RA*1000)/1000.0d)
Manga_Dec= Float(Round(Manga_Dec*1000)/1000.0d)
;Simard_BD_RA = Float(Round(Simard_BD_RA*1000)/1000.0d)
;Simard_BD_Dec= Float(Round(Simard_BD_Dec*1000)/1000.0d)

Manga_plate=Manga_list.plate
Manga_ifu=Manga_list.IFUDESIGN
Manga_plate_ifu=Manga_list.PLATEIFU

Pymorph_plate_ifu=Pymorph_list.PLATEIFU
Manga_ID_PYM=Pymorph_list.MANGA_ID
Redshift=Pymorph_list.Z
OBJID_PYM=Pymorph_list.OBJID
SPA_PYM=Pymorph_SPA.SPA_R





;###########################################
;  * Go to the next galaxy on the list
;###########################################
;if file_test(root_fits+'galaxies_in_progress.txt') eq 0 then start_val=0 $
;  else if file_test(root_fits+'galaxies_completed_SS.txt') eq 0 then start_val=0 $
;  else begin
;    readcol,root_fits+'galaxies_in_progress.txt',format='a',in_prog,comment='#',/silent
;    readcol,root_fits+'galaxies_completed_SS.txt',format='a',completed_SS,comment='#',/silent
;    readcol,root_fits+'galaxies_completed_SE.txt',format='a',completed_SE,comment='#',/silent
;    if completed_SS[-1] eq completed_SE[-1] and completed_SS[-1] eq in_prog[-1] then start_val=where(strtrim(Manga_plate_ifu,2) eq in_prog[-1])+1 $
;      else if completed_SS[-1] ne completed_SE[-1] then start_val=where(strtrim(Manga_plate_ifu,2) eq in_prog[-1]) $
;      else start_val=where(strtrim(Manga_plate_ifu,2) eq in_prog[-1])
;  endelse
   
   
; make sure the files below exist, and create them if not
spawn,'touch '+root_fits+'galaxies_in_progress.txt'
spawn,'touch '+root_fits+'galaxies_completed_SS.txt'
spawn,'touch '+root_fits+'galaxies_completed_SE.txt'

total_loops=n_elements(Manga_RA)
for loop=0,total_loops,1 do begin

  loop-=1   ;subtract a value so that the next line works without skipping a galaxy
  repeat loop+=1 until Manga_ifu[loop] ge 9000

  print,'***Now running for galaxy '+strtrim(loop,2)+' out of '+strtrim(total_loops,2)

  RA_in=Manga_RA[loop]
  dec_in=Manga_Dec[loop]

  ;identify galaxy in the Pymorph catalog using the RA and Dec
  plate=Manga_plate[loop]
  ifu=Manga_IFU[loop]
  plate_ifu=Manga_plate_ifu[loop]
  element=where(strtrim(Pymorph_plate_ifu,2) eq strtrim(plate_ifu,2))
  ;if element eq -1 or n_elements(element) gt 1 then stop
  print,plate_ifu
  
  ;read in the list of galaxies that have been tried to identify the next in the sequence   
  readcol,root_fits+'galaxies_in_progress.txt',format='a',in_prog,comment='#',/silent
  readcol,root_fits+'galaxies_completed_SS.txt',format='a',completed_SS,comment='#',/silent
  readcol,root_fits+'galaxies_completed_SE.txt',format='a',completed_SE,comment='#',/silent
 
  if n_elements(element) gt 1 then element=element[0]
  
  test=where(in_prog eq plate_ifu,cnt)
  if cnt ge 1 then begin
    ;if code finds that galaxy has been started
    print,'galaxy is running in another window, or has already been done. Moving on'
  endif else if element eq -1 then begin
    print,'galaxy is not in PYMORPH catalog. Moving on'
    openw,11,root_fits+'galaxies_in_progress.txt',/APPEND
    printf,11,plate_ifu,'    ',session
    close,11
  endif else begin
    ;if code finds that galaxy has not been started
    print,'galaxy is untouched, starting loop'
  
    ;adding the next galaxy to the in progress file to prevent another session repeating that fit
    openw,11,root_fits+'galaxies_in_progress.txt',/APPEND
    printf,11,plate_ifu,'    ',session
    close,11
  
    print, systime(0)


    ;if the fit was successful with PyMorph, run the buddi fit
    Failed_SS=Pymorph_list.FLAG_FAILED_S
    Failed_SE=Pymorph_list.FLAG_FAILED_SE
    SPA=SPA[element]
  
    ;identify bad fits from the PyMorph catalog (i.e. with Re < 1 pixel) and 
    ;flag them so the fits don't run
    Re_arcsec_ss=Pymorph_list.A_hl_S
    Re_arcsec_se_bulge=Pymorph_list.A_hl_SE_BULGE
    Re_arcsec_se_disk=Pymorph_list.A_hl_SE_DISK
    if (Re_arcsec_ss[element]/0.5) lt 1 then Failed_SS[element]=1
    if (Re_arcsec_se_disk[element]/0.5) lt 1 or (Re_arcsec_se_bulge[element]/0.5) lt 1 then Failed_SE[element]=1
  

    if Failed_SS[element] eq 0 or Failed_SE[element] eq 0  then begin
      ;  * Download the log-binned cube from MaNGA
      print,'galaxy = '+plate_ifu
      cube='manga-'+plate_ifu+'-LOGCUBE'
      if ~file_test(root+'fits/'+plate_ifu+'/',/DIRECTORY) then begin 
        spawn,'mkdir '+ root+'fits/'+plate_ifu+'/'
      endif
      working_dir=root+'fits/'+plate_ifu+'/'
  
      ;  * only download and unzip the datacube if it's not already downloaded
      if file_test(working_dir+cube+'.fits*') eq 0 then $
        spawn,'rsync -avz --no-motd rsync://data.sdss.org/dr16/manga/spectro/redux/v2_4_3/'+string(plate,format='(i4)')+'/stack/'+cube+'.fits.gz '+working_dir
      if file_test(working_dir+cube+'.fits') eq 0 then $
        spawn,'gunzip '+working_dir+cube+'.fits.gz'
    
  
      ;  * Create a PSF datacube
      if ~file_test(working_dir+cube+'_PSF.fits') then PSF_manga,working_dir,cube,root_files
      
      
      
      ;  * run the buddi_prep code to convert the units and create the bad pixel cube
      fits_read,working_dir+cube+'.fits',wave,h_wave,extname='WAVE'
      wave_log=alog10(wave)
      delvarx, wave
      if ~file_test(working_dir+cube+'_FLUX.fits') then BUDDI_manga_prep,working_dir,cube,/JY,/BADPIX
    
      ;  * Create 2 BUDDI start files, one for a single Sersic fit and one for a Sersic+exponential fit
      create_buddi_start_file,working_dir,cube,plate_ifu,SPA,Manga_list,Pymorph_list,loop,element,wave_log,/ONECOMP
      create_buddi_start_file,working_dir,cube,plate_ifu,SPA,Manga_list,Pymorph_list,loop,element,wave_log,/TWOCOMP
     
      
    
    
      ;###################################
      ; 1 comoponent fit
      ;###################################
      readcol,root_fits+'galaxies_failed_SS.txt',format='a',failed_fit_SS,comment='#',/silent
      readcol,root_fits+'galaxies_failed_SE.txt',format='a',failed_fit_SE,comment='#',/silent
      
      ;only run loop if galaxy hasn already failed and doesnt have a failed flag in Pymorph catalog
      temp=where(failed_fit_SS eq plate_ifu)
      temp2=where(completed_SS eq plate_ifu)

      if Failed_SS[element]  ne 1  and temp[0] eq -1 and temp2[0] eq -1 then begin
        ;here, we run buddi
        print,'***Starting SS fit, galaxy '+plate_ifu
        buddi,working_dir+'BUDDI_onecomp_'+plate_ifu+'.txt',/AUTO
        openw,22,root_fits+'galaxies_completed_SS.txt',/APPEND
        printf,22,plate_ifu
        close,22
  
        ;test if the fit was successful (i.e. the fit was completed)
        success=file_search(working_dir+'/IFU_decomp_1comp/image_slices/subcomps*', count=nfiles_subcomp)
        success2=file_search(working_dir+'/IFU_decomp_1comp/image_slices/galfitm*.feedme', count=nfiles_feedme)
      
        ;consider the fit successful if the final number of subcomps files with within 100 of the number 
        ;of input/feedme files (i.e. less than 100 fits failed)
        if nfiles_subcomp ge nfiles_feedme-100 and nfiles_feedme ne 0 then begin
          buddi_manga_final_flux,working_dir+'BUDDI_onecomp_'+plate_ifu+'.txt'
          openw,22,root_fits+'galaxies_successful_SS.txt',/APPEND
          printf,22,plate_ifu
          close,22
          buddi_plot_results, root+'fits/'+plate_ifu+'/',plate_ifu,/onecomp
          ;clean up the directories to save on storage
          spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/image_*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/badpix/*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/PSF/*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/sigma/*.fits'
        endif 
      
        ;if the fit failed, record that in the failed list
        if ~file_test(root_fits+plate_ifu+'/IFU_decomp_1comp/decomposed_data/',/DIRECTORY) and Failed_SS[element] eq 0 then begin
          openw,22,root_fits+'galaxies_failed_SS.txt',/APPEND
          printf,22,plate_ifu+'    failed_BUDDI_fit'
          close,22        
          spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/image_*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/badpix/*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/PSF/*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/sigma/*.fits'
        endif
      endif else if Failed_SS[element]  eq 1 then begin
        openw,22,root_fits+'galaxies_failed_SS.txt',/APPEND
        printf,22,plate_ifu+'    no_input_params'
        close,22
        Failed_SS[element]=1
        spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/image_*.fits'
        spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/badpix/*.fits'
        spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/PSF/*.fits'
        spawn,'rm '+working_dir+'/IFU_decomp_1comp/image_slices/sigma/*.fits'
      endif
    
      ;###################################
      ; 2 comoponent fit
      ;###################################
    
      temp=where(failed_fit_SE eq plate_ifu)
      temp2=where(completed_SE eq plate_ifu)

      if Failed_SE[element] eq 0 and temp[0] eq -1 and temp2[0] eq -1 then begin
        print,'***Starting SE fit, galaxy '+plate_ifu
      
        ;here, we run buddi
        buddi,working_dir+'BUDDI_twocomp_'+plate_ifu+'.txt',/AUTO
        openw,23,root_fits+'galaxies_completed_SE.txt',/APPEND
        printf,23,plate_ifu
        close,23

        ;test if the fit was successful
        success=file_search(working_dir+'/IFU_decomp_2comp/image_slices/subcomps*', count=nfiles_subcomp)
        success2=file_search(working_dir+'/IFU_decomp_2comp/image_slices/galfitm*.feedme', count=nfiles_feedme)

        if nfiles_subcomp ge nfiles_feedme-10 and nfiles_feedme ne 0 then begin
          buddi_manga_final_flux,working_dir+'BUDDI_twocomp_'+plate_ifu+'.txt'
          openw,23,root_fits+'galaxies_successful_SE.txt',/APPEND
          printf,23,plate_ifu
          close,23
          buddi_plot_results, root+'fits/'+plate_ifu+'/',plate_ifu,/twocomp
  
          ;clean up the directories to save on memory
          spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/image_*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/badpix/*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/PSF/*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/sigma/*.fits'


        endif 

        if ~file_test(root_fits+plate_ifu+'/IFU_decomp_2comp/decomposed_data/',/DIRECTORY) and Failed_SE[element] eq 0 then begin
          openw,22,root_fits+'galaxies_failed_SE.txt',/APPEND
          printf,22,plate_ifu+'    failed_BUDDI_fit'
          close,22
          spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/image_*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/badpix/*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/PSF/*.fits'
          spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/sigma/*.fits'
        endif

      endif else if Failed_SE[element] eq 1 then begin
        openw,22,root_fits+'galaxies_failed_SE.txt',/APPEND
        printf,22,plate_ifu+'    no_input_params'
        close,22
        Failed_SE[element]=1
        spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/image_*.fits'
        spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/badpix/*.fits'
        spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/PSF/*.fits'
        spawn,'rm '+working_dir+'/IFU_decomp_2comp/image_slices/sigma/*.fits'
      endif
    
    
    
      ;  * Clean up by deleting all the downloaded and intermediate files
;      spawn,'rm -r '+ root+'fits/'+plate_ifu+'/'
    endif else if Failed_SS[element] ne 0 and Failed_SE[element] ne 0  then begin
        ;if no input paramaters in the pyMorph catalog for either fit, make a note of this issue
        openw,22,root_fits+'galaxies_failed_SE.txt',/APPEND
        printf,22,plate_ifu+'    no_input_params'
        close,22
        openw,22,root_fits+'galaxies_failed_SS.txt',/APPEND
        printf,22,plate_ifu+'    no_input_params'
        close,22
    endif
    ;  * Move onto the next galaxy
    CD, root_fits
  endelse
endfor

CD,old_dir






end

