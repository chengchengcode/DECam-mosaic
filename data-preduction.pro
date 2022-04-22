;filename = ['c4d_201022_083746','c4d_201022_084315','c4d_201022_084843','c4d_201022_085411','c4d_201022_085940']

;make the file list for ooi data
spawn, 'ls ../../p7c2fbwwnuboj6gdhycjwqa5uhnvd12s/c4d_*ooi_i_v1.fits.fz', name_ooi
openw, lun, 'namelist.txt', /get_lun
for i = 0, n_elements(name_ooi) - 1 do printf, lun, strrep(name_ooi[i], '_ooi_i_v1.fits.fz', ''), format = '(a)'
free_lun, lun
readcol, 'namelist.txt', filename, format = 'a'



for i = 0LL, n_elements(filename) - 1 do begin
	for i_ext = 1, 61 do begin
			print, 61 - i_ext, n_elements(filename) - i, '	'+systime()	
		img = mrdfits(filename[i]+'_ooi_i_v1.fits.fz',i_ext,h)
		mask = mrdfits(filename[i]+'_ood_i_v1.fits.fz',i_ext,h_mask)

		weight = mrdfits(filename[i]+'_oow_i_v1.fits.fz',i_ext,h_weight)

		;shift 1 pixel weight map
		;FXADDPAR, h_weight, 'CRPIX1', sxpar(h_weight, 'CRPIX1') + 1, ' Reference pixel on this axis'
		;FXADDPAR, h_weight, 'CRPIX2', sxpar(h_weight, 'CRPIX2') + 1, ' Reference pixel on this axis'		
		
		;trim the edge of the weight image
    	;HEXTRACT, weight, h_weight, Newim, Newhd, 1, 2046, 1, 4094, /SILENT 

;	check the weight map:
;		writefits, filename[i]+'_ooi_i_v1_'+strtrim(i_ext, 2)+'_weight.fits', 1./img, h
;		writefits, filename[i]+'_oow_i_v1_'+strtrim(i_ext, 2)+'_CC.fits', newim, newhd
;		writefits, filename[i]+'_ooi_i_v1_'+strtrim(i_ext, 2)+'_weight-residual.fits', 1./img - newim * median(1./img)/median(newim), h
;	conclusion: weight map given by noao is about 1/err^2, aka inverse variation map

		ind_mask = where(mask ne 0)

		img[ind_mask] = alog10(-1)	;set the masked region as NAN
		weight[ind_mask] = 0			;set the masked region with 0 weight

		writefits, strrep( filename[i]+'_ooi_i_v1_'+strtrim(i_ext, 2)+'.fits', '../../p7c2fbwwnuboj6gdhycjwqa5uhnvd12s/', './multi-ext/'), img, h
		writefits, strrep( filename[i]+'_oow_i_v1_'+strtrim(i_ext, 2)+'.fits', '../../p7c2fbwwnuboj6gdhycjwqa5uhnvd12s/', './multi-ext/'), weight, h_weight
		




		;remove the background by noisechisel:
;		spawn, 'astnoisechisel '+strrep( filename[i]+'_ooi_i_v1_'+strtrim(i_ext, 2)+'.fits', '../../p7c2fbwwnuboj6gdhycjwqa5uhnvd12s/', './multi-ext/')+' --hdu=0

;cc_pause	
	endfor
endfor














end
