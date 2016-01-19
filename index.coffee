###
Vue Media Loader Directive

Loads an and <img> or background image with multiple sources, depending on
the viewport width. Use the `:media` attribute to pass in an obj with keys
`low`, `medium`, and `high` image sources.

Once the image is loaded, if will be set on the element and a class of
`media-loaded` will be added.

Usage:
	# Register the directive globally
	Vue.directive 'media-loader',     require 'vue-media-loader-directive'

	# Single image source string. Just add this to any element you want to load
	v-media-loader='/img/temp-project-marquee-low.png'

	# Bundle of media sizes. Should be a JS object with keys `low`, `medium`, `high`
	img(v-if='marquee' v-media-loader :media='[YOUR_OBJECT_REFERENCE]')
###

modernizr = require 'modernizr'
isHires = require './hires-test'
$win = $ window

module.exports =
	params: ['media']

	# Single breakpoint for comparison
	breakpoints:
		mobile: 420 	# low: mobile 1x
		desktop: 1024	# medium: mobile 2x, desktop 1x
		# high: others are desktop 2x

	bind: ->
		# The media source  defaults to the expression value
		@params.media = @expression if not @params.media?

		# Begin the preload process
		@determineMediaType() if @params.media?

	###
	The HTML element type determines how to apply the loaded media
	###
	determineMediaType: ->
		switch elType = @el.nodeName
			when 'IMG' then @loadImage()
			else @loadImage true #default, assume we're loading a background image

	###
	Finds the appropriate source to load, depending on the pixel density
	and width of the viewport
	###
	getImageSize: ->
		# backup to single image source if multiple aren't provided
		return @params.media if typeof @params.media == 'string'

		# trickle down to find the proper image source to load
		return @params.media.low if ($win.outerWidth() < @breakpoints.mobile)
		return @params.media.medium if (($win.outerWidth() < @breakpoints.desktop) or !isHires)
		return @params.media.high

	###
	Preloads image source and applies them to the element.
	###
	loadImage: (background = false) ->
		img = new Image()
		img.src = imgSrc = @getImageSize()

		img.onload = (e) =>
			$(@el).addClass 'media-loaded'
			$(@el).css('background-image', "url('"+imgSrc+"')") if background
			$(@el).attr('src', imgSrc) if not background
