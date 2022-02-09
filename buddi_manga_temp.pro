;quick code to do the final flux conversion and make the final plots if they are missing

pro buddi_manga_temp
;set up directories for fits and results
root='/raid/ejohnston/IDLWorkspace84/BUDDI_MaNGA/'
root_files='/raid/ejohnston/IDLWorkspace84/BUDDI_MaNGA/static_files/'
root_fits=root+'fits/'
root_output=root+'output/'

readcol,root_fits+'galaxies_in_progress.txt',format='a',in_prog,comment='#',/silent

for i=36,n_elements(in_prog)-1,1 do begin
  plate_ifu=in_prog[i]
  working_dir=root+'fits/'+plate_ifu+'/'
  success=file_search(working_dir+'/IFU_decomp_1comp/image_slices/subcomps*', count=nfiles_subcomp)
  success2=file_search(working_dir+'/IFU_decomp_1comp/image_slices/galfitm*.feedme', count=nfiles_feedme)

  ;if success eq 1 then begin
  if nfiles_subcomp ge nfiles_feedme-20 and nfiles_feedme ne 0 and ~file_test(working_dir+'/IFU_decomp_1comp/decomposed_data/decomposed_data_ergs/',/directory) then begin
    print,plate_ifu,'  one comp'
    buddi_manga_final_flux,working_dir+'BUDDI_onecomp_'+plate_ifu+'.txt'
    buddi_plot_results, root+'fits/'+plate_ifu+'/',plate_ifu,/onecomp
  endif




  success=file_search(working_dir+'/IFU_decomp_2comp/image_slices/subcomps*', count=nfiles_subcomp)
  success2=file_search(working_dir+'/IFU_decomp_2comp/image_slices/galfitm*.feedme', count=nfiles_feedme)

  ;if success eq 1 then begin
  if nfiles_subcomp ge nfiles_feedme-20 and nfiles_feedme ne 0 and ~file_test(working_dir+'/IFU_decomp_2comp/decomposed_data/decomposed_data_ergs/',/directory) then begin
    print,plate_ifu,'  two comp'
    buddi_manga_final_flux,working_dir+'BUDDI_twocomp_'+plate_ifu+'.txt'
    buddi_plot_results, root+'fits/'+plate_ifu+'/',plate_ifu,/twocomp
  endif
  
  
endfor

end