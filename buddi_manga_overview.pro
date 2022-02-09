;quick code to compile numbers of candidate galaxies for the paper

pro buddi_manga_overview

;set up directories for fits and results
root='/raid/ejohnston/IDLWorkspace84/BUDDI_MaNGA/'
root_files='/raid/ejohnston/IDLWorkspace84/BUDDI_MaNGA/static_files/'
root_fits=root+'fits/'
root_output=root+'output/'

readcol,root_fits+'galaxies_in_progress.txt',format='a',in_prog,comment='#',/silent
readcol,root_fits+'galaxies_completed_SS.txt',format='a',completed_SS,comment='#',/silent
readcol,root_fits+'galaxies_completed_SE.txt',format='a',completed_SE,comment='#',/silent

Pymorph_list=mrdfits(root_files+'manga-pymorph-DR15.fits',2) ;extensions 1,2,3 are g,r,i band results

plate_ifu=Pymorph_list.PLATEIFU
Failed_SS=Pymorph_list.FLAG_FAILED_S
Failed_SE=Pymorph_list.FLAG_FAILED_SE

extracted=strsplit(plate_ifu,'-',/extract)
IFU=fltarr(n_elements(extracted))
for i=0,n_elements(extracted)-1,1 do begin
  temp=extracted[i]
  IFU[i]=temp[1]
endfor

sample1=where(IFU ge 9100)
sample2=where(IFU ge 9100 and Failed_SS eq 0)
sample3=where(IFU ge 9100 and Failed_SE eq 0)

Print,'##################################################'
print,'Number of candidates (IFU size only): '+string(n_elements(sample1),format='(i5)')
print,'Number of candidates (SS): '+string(n_elements(sample2),format='(i5)')
print,'Number of candidates (SE): '+string(n_elements(sample3),format='(i5)')
Print,'##################################################'

stop
end