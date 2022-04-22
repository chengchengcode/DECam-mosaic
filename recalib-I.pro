path_to_data = './multi-ext/'
spawn, 'ls multi-ext/*ooi*', namelist

spawn, 'mkdir multi-ext-cat'
spawn, 'mkdir multi-ext-zpt'

tab = read_csv('adfs_des_all_v2.csv')

ra = tab.FIELD01
dec = tab.FIELD02

mag_r = tab.FIELD07

plot, ra, dec, ps = 3

openw, lun_zpt, 'zptcorr-I.txt', /get_lun

for i = 0, n_elements(namelist) - 1 do begin

	CATALOG_NAME = strrep( strrep(namelist[i], '.fits', '.cat.fits'), 'multi-ext', 'multi-ext-cat')
	calib_name = strrep( strrep(namelist[i], '.fits', '.txt'), 'multi-ext', 'multi-ext-cat')

	spawn, 'sextractor '+namelist[i]+' -c calib.sex -CATALOG_NAME '+CATALOG_NAME+' -MAG_ZEROPOINT 0'

	cat = mrdfits(CATALOG_NAME,1)

	plot, cat.mag_auto, cat.FWHM_IMAGE, ps = 3
	ind_star = where(cat.CLASS_STAR gt 0.95 and cat.mag_auto gt -14. and cat.mag_auto lt -11)
	oplot, cat[ind_star].mag_auto, cat[ind_star].FWHM_IMAGE, ps = 3, color = cgcolor('red')

;	mag_list = fltarr(n_elements(ind_star))

	openw, lun, calib_name, /get_lun
	for i_cat = 0, n_elements(ind_star) - 1 do begin
		index_inside = where( (cat[ind_star[i_cat]].alpha_J2000 - ra)^2. * cat[ind_star[i_cat]].delta_J2000^2 + (cat[ind_star[i_cat]].delta_J2000 - dec)^2 lt (10./3600.)^2. )
		if index_inside[0] eq -1 then continue
		
		dist_all = sphdist(cat[ind_star[i_cat]].alpha_J2000, cat[ind_star[i_cat]].delta_J2000, ra[index_inside], dec[index_inside], /deg) * 3600.d
	
		dist_min = min(dist_all, ind_min)

;		mag_list[i_cat] = mag_r[index_inside[ind_min]]

		printf, lun, cat[ind_star[i_cat]].alpha_J2000, cat[ind_star[i_cat]].delta_J2000, cat[ind_star[i_cat]].mag_auto, mag_r[index_inside[ind_min]], format = '(d,d,f,f)'
	endfor

	free_lun, lun

;	histogauss, mag_list - cat[ind_star].mag_auto, aa

;	MAGZERO = median(mag_list - cat[ind_star].mag_auto)

	readcol, calib_name, ra_calib, dec_calib, mag_auto_calib, mag_list_calib
	MAGZERO = median(mag_list_calib - mag_auto_calib)


	zpt_corr =  10. ^ ( (31.4 - MAGZERO) / 2.5 )

	image = mrdfits(namelist[i],0,h_image, /sil)
	image_weight = mrdfits(strrep(namelist[i], 'ooi', 'oow'),0,h_image_weight, /sil)

	writefits, strrep(strrep(namelist[i], '.fits', '-zpt.fits'), 'multi-ext', 'multi-ext-zpt'), zpt_corr * image, h_image
	writefits, strrep(strrep(strrep(namelist[i], 'ooi', 'oow'), '.fits', '-zpt.fits'), 'multi-ext', 'multi-ext-zpt'), (1./zpt_corr^2.) * image_weight, h_image_weight

	printf, lun_zpt, namelist[i], zpt_corr, format = '(a, f)'

;stop
endfor

free_lun, lun_zpt
























































stop
readcol, '../noisechisel-check/r-noisechisel.list', namelist, format = 'a'

openw, lun, 'noisechisel-r-fixsize.list', /get_lun
for i = 0, n_elements(namelist) - 1 do begin
	printf, lun, strrep(namelist[i], 'c4d', '../noisechisel-check/c4d'), format = '(a)'
endfor

free_lun, lun

readcol, '../noisechisel-check-u/u-noisechisel.list', namelist, format = 'a'
openw, lun, 'noisechisel-u-fixsize.list', /get_lun
for i = 0, n_elements(namelist) - 1 do begin
	printf, lun, strrep(namelist[i], './c4d', '../noisechisel-check-u/c4d'), format = '(a)'
endfor
free_lun, lun


readcol, '../noisechisel-check-g/g-noisechisel.list', namelist, format = 'a'
openw, lun, 'noisechisel-g-fixsize.list', /get_lun
for i = 0, n_elements(namelist) - 1 do begin
	printf, lun, strrep(namelist[i], './c4d', '../noisechisel-check-g/c4d'), format = '(a)'
endfor
free_lun, lun


spawn, 'swarp @noisechisel-r-fixsize.list -c stack.swarp -IMAGEOUT_NAME r.sci.median.noiseskysub.fixsize.fits -CENTER_TYPE MANUAL -CENTER 04:43:20.5,-53:45:04.6 -PIXELSCALE_TYPE MANUAL -PIXEL_SCALE 0.2 -IMAGE_SIZE 85092,67452 -RESAMPLING_TYPE LANCZOS3 -SUBTRACT_BACK N -MEM_MAX 2560 -COMBINE_BUFSIZE 2560

spawn, 'swarp @noisechisel-u-fixsize.list -c stack.swarp -IMAGEOUT_NAME u.sci.median.noiseskysub.fixsize.fits -CENTER_TYPE MANUAL -CENTER 04:43:20.5,-53:45:04.6 -PIXELSCALE_TYPE MANUAL -PIXEL_SCALE 0.2 -IMAGE_SIZE 85092,67452 -RESAMPLING_TYPE LANCZOS3 -SUBTRACT_BACK N -MEM_MAX 2560 -COMBINE_BUFSIZE 2560

spawn, 'swarp @noisechisel-g-fixsize.list -c stack.swarp -IMAGEOUT_NAME g.sci.median.noiseskysub.fixsize.fits -CENTER_TYPE MANUAL -CENTER 04:43:20.5,-53:45:04.6 -PIXELSCALE_TYPE MANUAL -PIXEL_SCALE 0.2 -IMAGE_SIZE 85092,67452 -RESAMPLING_TYPE LANCZOS3 -SUBTRACT_BACK N -MEM_MAX 2560 -COMBINE_BUFSIZE 2560

spawn, 'rm coadd.weight.fits







spawn, 'fpack -r u.sci.median.noiseskysub.fixsize.fits
spawn, 'fpack -r g.sci.median.noiseskysub.fixsize.fits
spawn, 'fpack -r r.sci.median.noiseskysub.fixsize.fits


















end
