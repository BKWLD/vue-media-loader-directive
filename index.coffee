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

isHires = require './hires-test'
$win = $ window

module.exports =
	params: ['media']

	# These breakpoints mirror ones set in Decoy's Models\Image
	breakpoints:
		xs: 420
		s:  768
		m:  1024
		l:  1366
		xl: 1920

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

		# The source is a string, return it instead of supporting breakpoints
		return @params.media if typeof @params.media == 'string'

		# Step through breakpoints (but the largest) to find which size to use
		win = $win.outerWidth()
		for size, width of _.omit(@breakpoints, 'xl')
			if win <= width
				return if isHires then @params.media[size+'2x'] else @params.media[size]

		# Default to the largest size
		return if isHires then @params.media.xl2x else @params.media.xl

	###
	Preloads image source and applies them to the element.
	###
	loadImage: (background = false) ->

		# Get the src or stop if none defined
		return unless imgSrc = @getImageSize()

		# Build Image element to watch for loads upon
		img = new Image()
		img.src = imgSrc = @getImageSize()

		# Set a class that the media is loadig
		$(@el).addClass 'media-loading'
		@vm.$dispatch 'mediaLoading', @el

		# Watch for the load to complete
		img.onload = (e) =>

			# Set src
			return unless @el # Make sure the elememt still exists
			if background
				$(@el).css('background-image', "url('"+imgSrc+"')")
			else
				$(@el).attr('src', imgSrc)

			# Adding timeout so transition can occur if loading from cache
			setTimeout =>
				$(@el).addClass 'media-loaded' if @el
				@vm.$dispatch 'mediaLoaded', @el if @vm
			, 50
