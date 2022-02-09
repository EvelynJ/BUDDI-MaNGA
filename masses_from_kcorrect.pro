; code to measure masses with kcorrect for Keerthana

pro masses_from_kcorrect
dir='/data2/ejohnston/BUDDI_MaNGA/Keerthana/'
input_file='GALFITM_SDSS_ugriz_kcorrect.fits'


;read in the magnitudes
input=mrdfits(dir+input_file,1 )
mass_marvin_ser=input.LOGMASS_MARVIN_SER
mass_marvin_petro=input.LOGMASS_MARVIN_PETRO
z=input.Z 
gal_in=input.PLATEIFU
c1_u=input.COMP1_MAG_u
c1_g=input.COMP1_MAG_g
c1_r=input.COMP1_MAG_r
c1_i=input.COMP1_MAG_i
c1_z=input.COMP1_MAG_z
c1_u_err=input.COMP1_MAG_u_ERR
c1_g_err=input.COMP1_MAG_g_ERR
c1_r_err=input.COMP1_MAG_r_ERR
c1_i_err=input.COMP1_MAG_i_ERR
c1_z_err=input.COMP1_MAG_z_ERR

c2_u=input.COMP2_MAG_u
c2_g=input.COMP2_MAG_g
c2_r=input.COMP2_MAG_r
c2_i=input.COMP2_MAG_i
c2_z=input.COMP2_MAG_z
c2_u_err=input.COMP2_MAG_u_ERR
c2_g_err=input.COMP2_MAG_g_ERR
c2_r_err=input.COMP2_MAG_r_ERR
c2_i_err=input.COMP2_MAG_i_ERR
c2_z_err=input.COMP2_MAG_z_ERR

mag_u=-2.5*alog10(10^(-0.4*c1_u)+10^(-0.4*c2_u))
mag_g=-2.5*alog10(10^(-0.4*c1_g)+10^(-0.4*c2_g))
mag_r=-2.5*alog10(10^(-0.4*c1_r)+10^(-0.4*c2_r))
mag_i=-2.5*alog10(10^(-0.4*c1_i)+10^(-0.4*c2_i))
mag_z=-2.5*alog10(10^(-0.4*c1_z)+10^(-0.4*c2_z))

mag_u_err=-2.5*alog10(10^(-0.4*(c1_u+c1_u_err))+10^(-0.4*(c2_u+c2_u_err)))-mag_u
mag_g_err=-2.5*alog10(10^(-0.4*(c1_g+c1_g_err))+10^(-0.4*(c2_g+c2_g_err)))-mag_g
mag_r_err=-2.5*alog10(10^(-0.4*(c1_r+c1_r_err))+10^(-0.4*(c2_r+c2_r_err)))-mag_r
mag_i_err=-2.5*alog10(10^(-0.4*(c1_i+c1_i_err))+10^(-0.4*(c2_i+c2_i_err)))-mag_i
mag_z_err=-2.5*alog10(10^(-0.4*(c1_z+c1_z_err))+10^(-0.4*(c2_z+c2_z_err)))-mag_z

openw,01,dir+'GALFITM_SDSS_ugriz_kcorrect_masses.txt'
printf,01,'#                                       BUDDI-MANGA                      |                  NSA '
printf,01,'#   PLATEIFU          Total mass           C1 mass            c2 mass    |    Sersic mass        Petrosian mass'

;run kcorrect
mass=fltarr(n_elements(mag_u))
c1_mass=fltarr(n_elements(mag_u))
c2_mass=fltarr(n_elements(mag_u))
for i=0,n_elements(mag_u)-1,1 do begin
  kc= sdss_kcorrect(z[i], mag=[mag_u[i],mag_g[i],mag_r[i],mag_i[i],mag_z[i]],err=[3*mag_u_err[i],3*mag_g_err[i],3*mag_r_err[i],3*mag_i_err[i],3*mag_z_err[i]], mass=mass_temp)
  mass[i]=mass_temp
  kc= sdss_kcorrect(z[i], mag=[c1_u[i],c1_g[i],c1_r[i],c1_i[i],c1_z[i]],err=[3*c1_u_err[i],3*c1_g_err[i],3*c1_r_err[i],3*c1_i_err[i],3*c1_z_err[i]], mass=mass_temp)
  c1_mass[i]=mass_temp
  kc= sdss_kcorrect(z[i], mag=[c2_u[i],c2_g[i],c2_r[i],c2_i[i],c2_z[i]],err=[3*c2_u_err[i],3*c2_g_err[i],3*c2_r_err[i],3*c2_i_err[i],3*c2_z_err[i]], mass=mass_temp)
  c2_mass[i]=mass_temp
  printf,01,gal_in[i],alog10(mass[i]),alog10(c1_mass[i]),alog10(c2_mass[i]),mass_marvin_ser[i],mass_marvin_petro[i],format='(a12,5f19.5)'
endfor
close,01

set_plot,'x'
plot,alog10(mass),mass_marvin_ser,psym=1,xrange=[8.5,11.5],yrange=[8.5,11.5],charsize=2,xtitle='BUDDI-MaNGA mass',ytitle='Mass from Marvin/NSA'
oplot,alog10(mass),mass_marvin_petro,color=cgcolor('red'),psym=2
oplot,[8,12],[8,12]
xyouts,11,8.5,'Sersic mass',charsiz=1.5
xyouts,11,8.3,'Petro mass',charsiz=1.5,color=cgcolor('red')

;save masses
stop
end
