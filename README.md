# Vue Media Loader Directive

Loads an and <img> or background image with multiple sources, depending on
the viewport width. Use the `:media` attribute to pass in an obj with keys
`low`, `medium`, and `high` image sources.

Once the image is loaded, if will be set on the element and a class of
`media-loaded` will be added.

*Usage:*

* Register the directive globally

	`Vue.directive 'media-loader',     require 'vue-media-loader-directive'`

* Single image source string. Just add this to any element you want to load

	`v-media-loader='/img/temp-project-marquee-low.png'`

* Bundle of media sizes. Should be a JS object with keys `low`, `medium`, `high`

	`img(v-if='marquee' v-media-loader :media='[YOUR_OBJECT_REFERENCE]')`
