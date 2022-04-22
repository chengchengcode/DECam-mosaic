# DECam-mosaic

Here is an example of stacking the CTIO/DECam image. Some process can be improved to save the hard drive space.

## 1, Mask science and weight image: data-preduction.pro

For the data from 2020, sometimes the weight image and science image have one pixel offset. 

## 2, Calibrated the individual images if necessary: recalib-I.pro

Somehow the zeropoint in the head file would leads to two branch at the bright side of the color-mag plot, which is caused by the small offset of the zeop point. So I re-calibrate each image. Here I save the images to new files. 

It is also ok to change the zeropoint with FLXSCALE in header, then swarp will change the pixel value into FLXSCALE times pixel value.

## 3, Background subtraction: bgsub-I.pro

If the background is subtracted by the astnoisechisel, then remember to update the header so that the swarp can read the header. Here I save the background subtracted image again. It is also ok to use the xxx_detected.fits images from astnoisechisel, but remember to use xxx_detected.fits[1] in the file list, and use xxx_detected.head for swarp.

## 4, Image stack: stack-i-list.pro

I use clip-weight for stacking. It is also ok to new head files with FLXSCALE, then swarp will find the xxx.fits and xxx.head files to stack them.
