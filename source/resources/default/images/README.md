# Halve the size of the JPG images we were given:

convert BRANDMARK_SISSVoc_Solid_small_optimised.jpg -resize x70 csiro-brandmark-resized.png
convert ARDC_logo_RGB_small_optimised.jpg -resize x65 ardc-logo-resized-65.png

# But now they're different height. Align the text that goes
# underneath them by making the shorter one taller, by adding white
# space underneath.  The CSIRO logo is the taller, at 70 px high. The
# ARDC logo size is 200x65. So make a "canvas" image that is 200x70,
# then compose them.

convert -size 200x70 xc:white ardc-logo-resized-canvas.png
convert ardc-logo-resized-canvas.png ardc-logo-resized-65.png -composite ardc-logo-resized-70.png