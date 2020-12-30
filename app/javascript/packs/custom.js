jQuery(document).ready(function($) {

  /*=====================
   1. Sticky Header
   ==========================*/
   // $("#sticky-header").stick_in_parent();
  // When the user scrolls the page, execute myFunction
  window.onscroll = function() {myFunction()};
  // Get the header
  var header = document.getElementById("sticky");
  // Add the sticky class to the header when you reach its scroll position. Remove "sticky" when you leave the scroll position
  function myFunction() {
    if (window.pageYOffset > 200) {
      header.classList.add("sticky");
    } else {
      header.classList.remove("sticky");
    }
  }

  /*=====================
   08. toggle nav
   ==========================*/
  $('.toggle-nav').on('click', function() {
    let origin = 'right'
    if($('.sm-horizontal.rtl').length == 1) {
      origin = 'left';
    }
    $('.sm-horizontal').css(origin, "0px");
  });
  $(".mobile-back").on('click', function() {
    let origin = 'right'
    if($('.sm-horizontal.rtl').length == 1) {
      origin = 'left';
    }
    $('.sm-horizontal').css(origin, "-410px");
  });

  /*=====================
   14.Header z-index js
   ==========================*/
  if ($(window).width() < 1199) {
    $('.header-2 .navbar .sidebar-bar, .header-2 .navbar .sidebar-back, .header-2 .mobile-search img').on('click', function() {
      if ($('#mySidenav').hasClass('open-side')) {
        $('.header-2 #main-nav .toggle-nav').css('z-index', '99');
      } else {
        $('.header-2 #main-nav .toggle-nav').css('z-index', '1');
      }
    });
    $('.sidebar-overlay').on('click', function() {
      $('.header-2 #main-nav .toggle-nav').css('z-index', '99');
    });
    $('.header-2 #search-overlay .closebtn').on('click', function() {
      $('.header-2 #main-nav .toggle-nav').css('z-index', '99');
    });
    $('.layout3-menu .mobile-search .ti-search, .header-2 .mobile-search .ti-search').on('click', function() {
      $('.layout3-menu #main-nav .toggle-nav, .header-2 #main-nav .toggle-nav').css('z-index', '1');
    });
  }

  /*=====================
   16 .category page
   ==========================*/
  $('.collapse-block-title').on('click', function(e) {
      e.preventDefault;
      var speed = 300;
      var thisItem = $(this).parent(),
          nextLevel = $(this).next('.collection-collapse-block-content');
      if (thisItem.hasClass('open')) {
          thisItem.removeClass('open');
          nextLevel.slideUp(speed);
      } else {
          thisItem.addClass('open');
          nextLevel.slideDown(speed);
      }
  });
  $('.color-selector ul li').on('click', function(e) {
      $(".color-selector ul li").removeClass("active");
      $(this).addClass("active");
  });
  //list layout view
  $('.list-layout-view').on('click', function(e) {
      $('.collection-grid-view').css('opacity', '0');
      $(".product-wrapper-grid").css("opacity", "0.2");
      $('.shop-cart-ajax-loader').css("display", "block");
      $('.product-wrapper-grid').addClass("list-view");
      $(".product-wrapper-grid").children().children().removeClass();
      $(".product-wrapper-grid").children().children().addClass("col-lg-12");
      setTimeout(function() {
          $(".product-wrapper-grid").css("opacity", "1");
          $('.shop-cart-ajax-loader').css("display", "none");
      }, 500);
  });
  //grid layout view
  $('.grid-layout-view').on('click', function(e) {
      $('.collection-grid-view').css('opacity', '1');
      $('.product-wrapper-grid').removeClass("list-view");
      $(".product-wrapper-grid").children().children().removeClass();
      $(".product-wrapper-grid").children().children().addClass("col-lg-3");

  });
  $('.product-2-layout-view').on('click', function(e) {
      if ($('.product-wrapper-grid').hasClass("list-view")) {} else {
          $(".product-wrapper-grid").children().children().removeClass();
          $(".product-wrapper-grid").children().children().addClass("col-lg-6");
      }
  });
  $('.product-3-layout-view').on('click', function(e) {
      if ($('.product-wrapper-grid').hasClass("list-view")) {} else {
          $(".product-wrapper-grid").children().children().removeClass();
          $(".product-wrapper-grid").children().children().addClass("col-lg-4");
      }
  });
  $('.product-4-layout-view').on('click', function(e) {
      if ($('.product-wrapper-grid').hasClass("list-view")) {} else {
          $(".product-wrapper-grid").children().children().removeClass();
          $(".product-wrapper-grid").children().children().addClass("col-lg-3");
      }
  });
  $('.product-6-layout-view').on('click', function(e) {
      if ($('.product-wrapper-grid').hasClass("list-view")) {} else {
          $(".product-wrapper-grid").children().children().removeClass();
          $(".product-wrapper-grid").children().children().addClass("col-lg-2");
      }
  });


  /*=====================
   17.filter sidebar js
   ==========================*/
  $('.sidebar-popup').on('click', function(e) {
      $('.open-popup').toggleClass('open');
      $('.collection-filter').css("left", "-15px");
  });
  $('.filter-btn').on('click', function(e) {
      $('.collection-filter').css("left", "-15px");
  });
  $('.filter-back').on('click', function(e) {
      $('.collection-filter').css("left", "-365px");
      $('.sidebar-popup').trigger('click');
  });

  $('.account-sidebar').on('click', function(e) {
      $('.dashboard-left').css("left", "0");
  });
  $('.filter-back').on('click', function(e) {
      $('.dashboard-left').css("left", "-365px");
  });

  /*=====================
   13. slick slider
   ==========================*/
  $('.product-right-slick').slick({
      slidesToShow: 1,
      slidesToScroll: 1,
      arrows: true,
      fade: true,
      asNavFor: '.slider-right-nav'
  });
  if ($(window).width() > 575) {
      $('.slider-right-nav').slick({
          vertical: true,
          verticalSwiping: true,
          slidesToShow: 3,
          slidesToScroll: 1,
          asNavFor: '.product-right-slick',
          arrows: false,
          infinite: true,
          dots: false,
          centerMode: false,
          focusOnSelect: true
      });
  } else {
      $('.slider-right-nav').slick({
          vertical: false,
          verticalSwiping: false,
          slidesToShow: 3,
          slidesToScroll: 1,
          asNavFor: '.product-right-slick',
          arrows: false,
          infinite: true,
          centerMode: false,
          dots: false,
          focusOnSelect: true,
          responsive: [{
              breakpoint: 576,
              settings: {
                  slidesToShow: 3,
                  slidesToScroll: 1
              }
          }]
      });
  }


  $('#quick-view').on('show.bs.modal', function (event) {
    let name = $(event.relatedTarget).data('name');
    let image = $(event.relatedTarget).data('image');
    let price = $(event.relatedTarget).data('price');
    let details = $(event.relatedTarget).data('details');
    let view_detail = $(event.relatedTarget).data('view-detail');

    // console.log('productid', productid);
    $(this).find('.modal-body .product-name').text(name);
    $(this).find('.modal-body .product-image').attr("src", image);
    $(this).find('.modal-body .product-price').text(price);
    $(this).find('.modal-body .product-details').text(details);
    $(this).find('.modal-body .product-view-detail').attr("href", view_detail);
  })

  /*=====================
   22. Menu js
   ==========================*/
  $(function() {
    $('#main-menu').smartmenus({
        subMenusSubOffsetX: 1,
        subMenusSubOffsetY: -8
    });
    $('#sub-menu').smartmenus({
        subMenusSubOffsetX: 1,
        subMenusSubOffsetY: -8
    });
  });

});