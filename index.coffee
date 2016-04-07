###
Vue Media Loader Directive

Loads an and <img> or background image with multiple sources, depending on
the viewport width. Use the `:media` attribute to pass in an obj with keys
`low`, `medium`, and `high` image sources.

Once the image is loaded, if will be set on the element and a class of
`media-loaded` will be added.

Usage:

	# Register the directive globally
	Vue.directive 'media-loader', require 'vue-media-loader-directive'

	# Single image source string. Just add this to any element you want to load
	div(v-media-loader.literal='/img/temp-project-marquee-low.png')

	# Bundle of media sizes. Should be a JS object with keys like xs, xs2x, s, etc
	img(v-if='marquee' v-media-loader='YOUR_OBJECT_REFERENCE')

	# Get just the size specified in PHP, useful for small sized things
	div(v-media-loader.native='headshot')
###

isHires = require './hires-test'
$win = $ window

module.exports =

	# These breakpoints mirror ones set in Decoy's Models\Image
	breakpoints:
		xs: 420
		s:  768
		m:  1024
		l:  1366
		xl: 1920

	# Begin the preload process
	update: (@media) -> @determineMediaType() if @media

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
		return @media if typeof @media == 'string'

		# Don't serve different sizes, just different DPI versions at the L size
		if @modifiers.native
			return if isHires then @media.l2x else @media.l

		# Step through breakpoints (but the largest) to find which size to use
		win = $win.outerWidth()
		for size, width of _.omit(@breakpoints, 'xl')
			if win <= width
				return if isHires then @media[size+'2x'] else @media[size]

		# Default to the largest size
		return if isHires then @media.xl2x else @media.xl

	###
	Preloads image source and applies them to the element.
	###
	loadImage: (background = false) ->

		# Get the src or stop if none defined
		return unless imgSrc = @getImageSize()

		# Build Image element to watch for loads upon
		img = new Image()
		img.src = imgSrc

		# Set a class that the media is loadig
		$(@el).addClass 'media-loading'
		@vm.$dispatch 'mediaLoading', @el

		# Watch for the load to complete
		img.onload = (e) =>
			return unless @el # Make sure the elememt still exists
			$el = $(@el)

			# Set as css background style
			if background
				styles = backgroundImage: "url('#{imgSrc}')"
				if @media.bkgd_pos
					styles.backgroundPosition = @media.bkgd_pos
				$el.css styles

			# Set img tag src
			else
				$el.attr('src', imgSrc)

			# Set title / alt attribute
			if @media.title
				attribute = if background then 'aria-title' else 'alt'
				$el.attr attribute, @media.title

			# Adding timeout so transition can occur if loading from cache
			setTimeout =>
				$el.addClass 'media-loaded' if @el
				@vm.$dispatch 'mediaLoaded', @el if @vm
			, 50
