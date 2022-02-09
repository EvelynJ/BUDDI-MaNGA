;code to run through all the buddi_manga directories and clean the images I no longer need and can recreate

pro clean_buddi_manga
root='/data2/ejohnston/BUDDI_MaNGA/fits/'
subdir=['IFU_decomp_1comp/','IFU_decomp_2comp/','IFU_decomp_1comp_PYM/','IFU_decomp_2comp_PYM/']


files=file_search(root+'*',count=nfiles,/MARK_DIRECTORY)
for n=0,nfiles-1,1 do begin
;for n=3,3,1 do begin
  print,'cleaning directory '+string(n,format='(i5)')+' of '+string(nfiles-1,format='(i5)')
  print,files[n]
  for j=0,3,1 do begin
    if file_test(files[n]+subdir[j]) eq 1 then begin
      spawn,'rm '+files[n]+subdir[j]+'image_slices/image_*'
      spawn,'rm -r '+files[n]+subdir[j]+'image_slices/badpix/'
      spawn,'rm -r '+files[n]+subdir[j]+'image_slices/PSF/'
      spawn,'rm -r '+files[n]+subdir[j]+'image_slices/sigma/'
      spawn,'rm -r '+files[n]+subdir[j]+'image_slices/old_fits/'
      if j eq 0 then begin
        spawn,'rm '+files[n]+subdir[j]+'image_slices_poly2/image_*'
        spawn,'rm -r '+files[n]+subdir[j]+'image_slices_poly2/badpix/'
        spawn,'rm -r '+files[n]+subdir[j]+'image_slices_poly2/PSF/'
        spawn,'rm -r '+files[n]+subdir[j]+'image_slices_poly2/sigma/'
        spawn,'rm -r '+files[n]+subdir[j]+'image_slices_poly2/old_fits/'
      endif
    endif
  endfor
endfor
stop
end
