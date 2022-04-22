cd, 'multi-ext-bgsub'

spawn, 'ls ../multi-ext-zpt/*ooi*', namelist

openw, lun, '../i-noisechisel.list',/get_lun

openw, lun_w, '../iw-noisechisel.list',/get_lun

for i = 0, n_elements(namelist) - 1 do begin
	spawn, 'astnoisechisel ' + namelist[i]+' --hdu=0'

	img = mrdfits( strrep(strrep(namelist[i], '../multi-ext-zpt/', '../multi-ext-bgsub/'), '.fits', '_detected.fits'),1,h )
	h_org = headfits('../multi-ext/'+strrep(namelist[i], '-zpt_detected.fits[1]', '.fits'))

	writefits, strrep(strrep(namelist[i], '../multi-ext-zpt/', '../multi-ext-bgsub/'), '.fits', '-bgsub.fits'), img, h_org

	printf, lun, strrep(strrep(namelist[i], '../multi-ext-zpt/', '../multi-ext-bgsub/'), '.fits', '-bgsub.fits'), format = '(a)'
	printf, lun_w, strrep(namelist[i], 'ooi', 'oow'),format = '(a)'
	flush, lun
	flush, lun_w

;stop
endfor
free_lun,lun
free_lun,lun_w
cd, '..
end
