pro interpolate_stellar_templates

dir='/data2/ejohnston/BUDDI_MaNGA/miles_models_new/'
age_arr=['00.0631','00.0794','00.1000','00.1259','00.1585','00.1995','00.2512','00.3162','00.3981','00.5012','00.6310','00.7943','01.0000','01.2589','01.5849','01.9953','02.5119','03.1623','03.9811','05.0119','06.3096','07.9433','10.0000','12.5893','15.8489']

for i=0,n_elements(age_arr)-1,1 do begin
  fits_read,dir+'Mun1.30Zp0.00T'+age_arr[i]+'_iPp0.00_baseFe_linear_FWHM_2.51.fits',spec_0_0,h
  fits_read,dir+'Mun1.30Zm0.40T'+age_arr[i]+'_iPp0.00_baseFe_linear_FWHM_2.51.fits',spec_0_4,h
  fits_write,dir+'Mun1.30Zm0.20T'+age_arr[i]+'_iPp0.00_baseFe_linear_FWHM_2.51.fits',0.5*(spec_0_0+spec_0_4),h
  print,dir+'Mun1.30Zm0.20T'+age_arr[i]+'_iPp0.00_baseFe_linear_FWHM_2.51.fits'
endfor





end
