###
test for retina / high resolution / high pixel density

returns a boolean
	true: pixel density > 1
	false: pixel density = 1
###
isHires = ->

	# starts with default value for modern browsers
	dpr = window.devicePixelRatio or
		# fallback for IE
		(window.screen.deviceXDPI / window.screen.logicalXDPI) or
		#default value
		1

	return (dpr > 1)

module.exports = isHires()
