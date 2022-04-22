
;wait, 25LL * 60LL * 60LL

band = 'i'

openw, lun, band+'.list',/get_lun
openw, lun_w, band+'w.list',/get_lun

spawn, 'ls ../'+band+'/multi-ext-bgsub/*bgsub.fits', namelist

for i = 0, n_elements(namelist) - 1 do begin
	if strmid(namelist[i],52,2) eq '31' then continue

	printf, lun, namelist[i], format = '(a)'
	printf, lun_w, strrep(strrep(strrep(namelist[i], 'multi-ext-bgsub', 'multi-ext-zpt'), 'ooi', 'oow'), '-bgsub.fits', '.fits'), format = '(a)'

	;h = headfits(namelist[i])
	;sxaddpar, h, 'FLXSCALE', 1.
	;forprint, h, textout = strrep(namelist[i], '.fits', '.head'), /noc, /sil

endfor

free_lun, lun
free_lun, lun_w

stop
;wait, 10LL * 60 * 60LL

spawn, 'swarp @'+band+'.list -c stack.swarp -IMAGEOUT_NAME '+band+'.sci.clipweighted.fixsize.fits -COMBINE_TYPE CLIPPED -WEIGHT_IMAGE @'+band+'w.list -WEIGHT_TYPE MAP_WEIGHT -SUBTRACT_BACK N -MEM_MAX 2560 -COMBINE_BUFSIZE 2560'
spawn, 'fpack -r '+band+'.sci.clipweighted.fixsize.fits'






end