/*-----------------------------------------------------------------------------------*/
/*  WordPress
/*-----------------------------------------------------------------------------------*/
jQuery(document).ready(function() { 
	
	/**
	 * Mega Menu Stuff
	 */
	jQuery('nav .wpb_column').unwrap().parent().removeClass('subnav').addClass('mega-menu');
	jQuery('.mega-menu h4').each(function(){
		var $text = jQuery(this).text();
		jQuery(this).next().find('ul').prepend('<li><span class="title">'+ $text +'</span></li>')
		jQuery(this).remove();
	});
	jQuery('.mega-menu ul').removeClass('menu').unwrap().unwrap().unwrap().wrap('<li />');
	jQuery('.mega-menu > div > li').unwrap();
	
	/**
	 * Forms
	 */
	jQuery('.custom-forms .wpcf7-checkbox .wpcf7-list-item, .custom-forms .gfield_checkbox > li').addClass('checkbox-option').prepend('<div class="inner" />');
	jQuery('.custom-forms .wpcf7-radio .wpcf7-list-item, .custom-forms .gfield_radio > li').addClass('radio-option').prepend('<div class="inner" />');
	
	/**
	 * Single post stuff
	 */
	jQuery('.feed-item .more-link').parent('p').remove();
	
	/**
	 * Select items
	 */
	jQuery('select').wrap('<div class="select-option" />').parent().prepend('<i class="ti-angle-down"></i>');

	jQuery('a[rel*="attachment"]').attr('data-lightbox', 'true');
	
});
/*-----------------------------------------------------------------------------------*/
/*	Document Ready Stuff
/*-----------------------------------------------------------------------------------*/
var mr_firstSectionHeight,
    mr_nav,
    mr_navOuterHeight,
    mr_navScrolled = false,
    mr_navFixed = false,
    mr_outOfSight = false,
    mr_floatingProjectSections,
    mr_scrollTop = 0;

jQuery(document).ready(function() { 
    "use strict";
    
    //Cache Selectors
    var $window = jQuery(window);

    //WooCommerce VC Element Fixes
    jQuery('.woocommerce.columns-2 .col-sm-4').addClass('col-sm-6').removeClass('col-sm-4');
    jQuery('.woocommerce.columns-2 .col-md-4').addClass('col-md-6').removeClass('col-md-4');
    jQuery('.woocommerce.columns-4 .col-sm-4').addClass('col-sm-3').removeClass('col-sm-4');
    jQuery('.woocommerce.columns-4 .col-md-4').addClass('col-md-3').removeClass('col-md-4');

    // Update scroll variable for scrolling functions
    addEventListener('scroll', function() {
        mr_scrollTop = window.pageYOffset;
    }, false);

    // Append .background-image-holder <img>'s as CSS backgrounds
    jQuery('.background-image-holder').each(function() {
        var imgSrc = jQuery(this).children('img').attr('src');
        jQuery(this).css('background', 'url("' + imgSrc + '")');
        jQuery(this).children('img').hide();
        jQuery(this).css('background-position', 'initial');
    });

    // Fade in background images
    setTimeout(function() {
        jQuery('.background-image-holder').each(function() {
            jQuery(this).addClass('fadeIn');
        });
    }, 200);


    // Icon bulleted lists
	jQuery('ul[data-bullet]').each(function(){
	   var bullet = jQuery(this).attr('data-bullet');
	   jQuery(this).find('li').prepend('<i class="'+bullet+'"></i>');
	});

    // Checkboxes
    jQuery('body').on('click', '.checkbox-option', function(){
        jQuery(this).toggleClass('checked');
		var checkbox = jQuery(this).find('input');
		if (checkbox.prop('checked') === false) {
		    checkbox.prop('checked', true);
		} else {
		    checkbox.prop('checked', false);
		}
    });

    // Radio Buttons
    jQuery('body').on('click', '.radio-option', function(){
		var checked = jQuery(this).hasClass('checked'); // Get the current status of the radio
		
		var name = jQuery(this).find('input').attr('name'); // Get the name of the input clicked
		
		if (!checked) {
		
		    jQuery('input[name="' + name + '"]').parent().removeClass('checked');
		
		    jQuery(this).addClass('checked');
		
		    jQuery(this).find('input').prop('checked', true);
		
		}
    });

    // Accordions
    jQuery('.accordion').not('.team-member .accordion').each(function(){
    	jQuery('li', this).eq(0).addClass('active');
    });
    
    jQuery('.accordion li').click(function() {
        if (jQuery(this).closest('.accordion').hasClass('one-open')) {
            jQuery(this).closest('.accordion').find('li').removeClass('active');
            jQuery(this).addClass('active');
        } else {
            jQuery(this).toggleClass('active');
        }
		if(typeof window.mr_parallax !== "undefined"){
		    setTimeout(mr_parallax.windowLoad, 500);
		}
    });

    // Tabbed Content
    jQuery('.tabbed-content').each(function() {
    	jQuery('li', this).eq(0).addClass('active');
        jQuery(this).append('<ul class="content"></ul>');
    });

    jQuery('.tabs li').each(function() {
        var originalTab = jQuery(this),
            activeClass = "";
        if (originalTab.is('.tabs > li:first-child')) {
            activeClass = ' class="active"';
        }
        var tabContent = originalTab.find('.tab-content').detach().wrap('<li' + activeClass + '></li>').parent();
        originalTab.closest('.tabbed-content').find('.content').append(tabContent);
    });

    jQuery('.tabs li').click(function() {
        jQuery(this).closest('.tabs').find('li').removeClass('active');
        jQuery(this).addClass('active');
        var liIndex = jQuery(this).index() + 1;
        jQuery(this).closest('.tabbed-content').find('.content>li').removeClass('active');
        jQuery(this).closest('.tabbed-content').find('.content>li:nth-of-type(' + liIndex + ')').addClass('active');
    });

    // Progress Bars
    jQuery('.progress-bar').each(function() {
        jQuery(this).css('width', jQuery(this).attr('data-progress') + '%');
    });

    // Navigation
    if (!jQuery('nav').hasClass('fixed') && !jQuery('nav').hasClass('absolute')) {

        // Make nav container height of nav
        jQuery('.nav-container').css('min-height', jQuery('nav').outerHeight(true));

        jQuery(window).resize(function() {
            jQuery('.nav-container').css('min-height', jQuery('nav').outerHeight(true));
        });

        // Compensate the height of parallax element for inline nav
        if (jQuery(window).width() > 768) {
            jQuery('.parallax:nth-of-type(1) .background-image-holder').css('top', -(jQuery('nav').outerHeight(true)));
        }

        // Adjust fullscreen elements
        if (jQuery(window).width() > 768) {
            jQuery('section.fullscreen:nth-of-type(1)').css('height', (jQuery(window).height() - jQuery('nav').outerHeight(true)));
        }

    } else {
        jQuery('body').addClass('nav-is-overlay');
        
        // Compensate the height of parallax element for inline nav
        if (jQuery(window).width() > 768) {
        	if(jQuery('body').hasClass('admin-bar')){
            	jQuery('.parallax:nth-of-type(1) .background-image-holder').css('top', -32);
        	} else {
        		jQuery('.parallax:nth-of-type(1) .background-image-holder').css('top', 0);	
        	}
        }
    }

    if (jQuery('nav').hasClass('bg-dark')) {
        jQuery('.nav-container').addClass('bg-dark');
    }


    // Fix nav to top while scrolling
    mr_nav = jQuery('body .nav-container nav:first');
    mr_navOuterHeight = jQuery('body .nav-container nav:first').outerHeight();
    window.addEventListener("scroll", updateNav, false);

    // Menu dropdown positioning
    jQuery('.menu > li > ul').each(function() {
        var menu = jQuery(this).offset();
        var farRight = menu.left + jQuery(this).outerWidth(true);
        if (farRight > jQuery(window).width() && !jQuery(this).hasClass('mega-menu')) {
            jQuery(this).addClass('make-right');
        } else if (farRight > jQuery(window).width() && jQuery(this).hasClass('mega-menu')) {
            var isOnScreen = jQuery(window).width() - menu.left;
            var difference = jQuery(this).outerWidth(true) - isOnScreen;
            jQuery(this).css('margin-left', -(difference));
        }
    });

    // Mobile Menu
    jQuery('.mobile-toggle').click(function() {
        jQuery('.nav-bar').toggleClass('nav-open');
        jQuery(this).toggleClass('active');
    });

    jQuery('.menu li').click(function(e) {
        if (!e) e = window.event;
        e.stopPropagation();
        if (jQuery(this).find('ul').length) {
            jQuery(this).toggleClass('toggle-sub');
        } else {
            jQuery(this).parents('.toggle-sub').removeClass('toggle-sub');
        }
    });
	
	jQuery('.menu li a[href^="#"]:not(a[href="#"])').click(function() {
	    if (jQuery(this).hasClass('inner-link')){
	        jQuery(this).closest('.nav-bar').removeClass('nav-open');
	    }
	});
	
    jQuery('.module.widget-handle').click(function() {
        jQuery(this).toggleClass('toggle-widget-handle');
    });
    
    jQuery('.search-widget-handle .search-form input').click(function(e){
        if (!e) e = window.event;
        e.stopPropagation();
    });
    
    // Offscreen Nav
	if(jQuery('.offscreen-toggle').length){
		jQuery('body').addClass('has-offscreen-nav');
	} else{
        jQuery('body').removeClass('has-offscreen-nav');
    }
	
	jQuery('.offscreen-toggle').click(function(){
		jQuery('.main-container').toggleClass('reveal-nav');
		jQuery('nav').toggleClass('reveal-nav');
		jQuery('.offscreen-container').toggleClass('reveal-nav');
	});
	
	jQuery('.main-container').click(function(){
		if(jQuery(this).hasClass('reveal-nav')){
			jQuery(this).removeClass('reveal-nav');
			jQuery('.offscreen-container').removeClass('reveal-nav');
			jQuery('nav').removeClass('reveal-nav');
		}
	});
	
	jQuery('.offscreen-container a').click(function(){
		jQuery('.offscreen-container').removeClass('reveal-nav');
		jQuery('.main-container').removeClass('reveal-nav');
		jQuery('nav').removeClass('reveal-nav');
	});
	
}); 
/*-----------------------------------------------------------------------------------*/
/*	Window Load Stuff
/*-----------------------------------------------------------------------------------*/
jQuery(window).load(function() { 
    "use strict";
    
    var $window = jQuery(window);

    // Initialize Masonry
    if (jQuery('.masonry').length) {
        var container = document.querySelector('.masonry');
        var msnry = new Masonry(container, {
            itemSelector: '.masonry-item'
        });

        msnry.on('layoutComplete', function() {

            mr_firstSectionHeight = jQuery('.main-container section:nth-of-type(1)').outerHeight(true);
            if( 0 == jQuery('section').length || 1 == jQuery('section').length ){
            	mr_firstSectionHeight = 300;	
            }

            // Fix floating project filters to bottom of projects container
            if (jQuery('.filters.floating').length) {
                setupFloatingProjectFilters();
                updateFloatingFilters();
                window.addEventListener("scroll", updateFloatingFilters, false);
            }

            jQuery('.masonry').addClass('fadeIn');
            jQuery('.masonry-loader').addClass('fadeOut');
            if (jQuery('.masonryFlyIn').length) {
                masonryFlyIn();
            }
        });

        msnry.layout();
    }

    // Initialize twitter feed
    var setUpTweets = setInterval(function() {
        if (jQuery('.tweets-slider').find('li.flex-active-slide').length) {
            clearInterval(setUpTweets);
            return;
        } else {
            if (jQuery('.tweets-slider').length) {
                jQuery('.tweets-slider').flexslider({
                    directionNav: false,
                    controlNav: false
                });
            }
        }
    }, 500);

    mr_firstSectionHeight = jQuery('.main-container section:nth-of-type(1)').outerHeight(true);
    if( 0 == jQuery('section').length || 1 == jQuery('section').length ){
    	mr_firstSectionHeight = 300;	
    }
	
	$window.trigger('resize');
	
	setTimeout(function(){
		$window.trigger('resize');
	}, 2500);
	
	//jQuery('.perm-fixed-nav').css('padding-top', jQuery('.nav-container').css('min-height'));
	
    if(typeof window.mr_parallax !== "undefined"){
        setTimeout(mr_parallax.windowLoad, 500);
    }

}); 
/*-----------------------------------------------------------------------------------*/
/*	Custom Functions
/*-----------------------------------------------------------------------------------*/
function updateNav() {

    var scrollY = mr_scrollTop;

    if (scrollY <= 0) {
        if (mr_navFixed) {
            mr_navFixed = false;
            mr_nav.removeClass('fixed');
        }
        if (mr_outOfSight) {
            mr_outOfSight = false;
            mr_nav.removeClass('outOfSight');
        }
        if (mr_navScrolled) {
            mr_navScrolled = false;
            mr_nav.removeClass('scrolled');
        }
        return;
    }

    if (scrollY > mr_firstSectionHeight) {
        if (!mr_navScrolled) {
            mr_nav.addClass('scrolled');
            mr_navScrolled = true;
            return;
        }
    } else {
        if (scrollY > mr_navOuterHeight) {
            if (!mr_navFixed) {
                mr_nav.addClass('fixed');
                mr_navFixed = true;
            }

            if (scrollY > mr_navOuterHeight * 2) {
                if (!mr_outOfSight) {
                    mr_nav.addClass('outOfSight');
                    mr_outOfSight = true;
                }
            } else {
                if (mr_outOfSight) {
                    mr_outOfSight = false;
                    mr_nav.removeClass('outOfSight');
                }
            }
        } else {
            if (mr_navFixed) {
                mr_navFixed = false;
                mr_nav.removeClass('fixed');
            }
            if (mr_outOfSight) {
                mr_outOfSight = false;
                mr_nav.removeClass('outOfSight');
            }
        }

        if (mr_navScrolled) {
            mr_navScrolled = false;
            mr_nav.removeClass('scrolled');
        }

    }
}
function capitaliseFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}
function masonryFlyIn() {
    var $items = jQuery('.masonryFlyIn .masonry-item');
    var time = 0;

    $items.each(function() {
        var item = jQuery(this);
        setTimeout(function() {
            item.addClass('fadeIn');
        }, time);
        time += 170;
    });
}
function setupFloatingProjectFilters() {
    mr_floatingProjectSections = [];
    jQuery('.filters.floating').closest('section').each(function() {
        var section = jQuery(this);

        mr_floatingProjectSections.push({
            section: section.get(0),
            outerHeight: section.outerHeight(),
            elemTop: section.offset().top,
            elemBottom: section.offset().top + section.outerHeight(),
            filters: section.find('.filters.floating'),
            filersHeight: section.find('.filters.floating').outerHeight(true)
        });
    });
}
function updateFloatingFilters() {
    var l = mr_floatingProjectSections.length,
    navHeight = wp_data.nav_height - 7;
    
    if( jQuery('body').hasClass('admin-bar') ){
    	navHeight = navHeight + 32;	
    }
    
    while (l--) {
        var section = mr_floatingProjectSections[l];

        if ((section.elemTop < mr_scrollTop) && typeof window.mr_variant == "undefined" ) {
            section.filters.css({
                position: 'fixed',
                top: '16px',
                bottom: 'auto'
            });
            if (mr_navScrolled) {
                section.filters.css({
                    transform: 'translate3d(0,'+ navHeight +'px,0)'
                });
            }
            if (mr_scrollTop > (section.elemBottom - 70)) {
                section.filters.css({
                    position: 'absolute',
                    bottom: '16px',
                    top: 'auto'
                });
                section.filters.css({
                    transform: 'translate3d(0,0,0)'
                });
            }
        } else {
            section.filters.css({
                position: 'absolute',
                transform: 'translate3d(0,0,0)'
            });
        }
    }
}
var mr_cookies = {
getItem: function (sKey) {
  if (!sKey) { return null; }
  return decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null;
},
setItem: function (sKey, sValue, vEnd, sPath, sDomain, bSecure) {
  if (!sKey || /^(?:expires|max\-age|path|domain|secure)$/i.test(sKey)) { return false; }
  var sExpires = "";
  if (vEnd) {
    switch (vEnd.constructor) {
      case Number:
        sExpires = vEnd === Infinity ? "; expires=Fri, 31 Dec 9999 23:59:59 GMT" : "; max-age=" + vEnd;
        break;
      case String:
        sExpires = "; expires=" + vEnd;
        break;
      case Date:
        sExpires = "; expires=" + vEnd.toUTCString();
        break;
    }
  }
  document.cookie = encodeURIComponent(sKey) + "=" + encodeURIComponent(sValue) + sExpires + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "") + (bSecure ? "; secure" : "");
  return true;
},
removeItem: function (sKey, sPath, sDomain) {
  if (!this.hasItem(sKey)) { return false; }
  document.cookie = encodeURIComponent(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + (sDomain ? "; domain=" + sDomain : "") + (sPath ? "; path=" + sPath : "");
  return true;
},
hasItem: function (sKey) {
  if (!sKey) { return false; }
  return (new RegExp("(?:^|;\\s*)" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test(document.cookie);
},
keys: function () {
  var aKeys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/);
  for (var nLen = aKeys.length, nIdx = 0; nIdx < nLen; nIdx++) { aKeys[nIdx] = decodeURIComponent(aKeys[nIdx]); }
  return aKeys;
}
};