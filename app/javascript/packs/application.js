// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/activestorage").start()
require("channels")

var $ = require( "jquery" )

require("slick-carousel")
require("packs/menu")
require("packs/lazysizes.min")
require("packs/price-range")
require("packs/jquery.elevatezoom")
require("packs/custom")

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)

import "slick-carousel/slick/slick.scss"
import "slick-carousel/slick/slick-theme.scss"
import 'bootstrap';
import 'stylesheets/application.scss';
