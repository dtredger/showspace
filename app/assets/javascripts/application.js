// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
// run Rails.application.config.assets.paths in console to see assets path
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require_directory ./items
//= require_directory ./users

$(function() {
  $(document).foundation({
      reveal: {
//          animation: 'fade',
//          animation_speed: 5000,
          close_on_background_click: true
      },
      orbit: {
          timer_speed: 2000,
          pause_on_hover: true // Pauses on the current slide while hovering
      },
      joyride: {
          expose                   : false,     // turn on or off the expose feature
          modal                    : true,      // Whether to cover page with modal during the tour
          keyboard                 : true,      // enable left, right and esc keystrokes
          tip_location             : 'bottom',  // 'top' or 'bottom' in relation to parent
          nub_position             : 'auto',    // override on a per tooltip bases
          scroll_speed             : 1500,      // Page scrolling speed in milliseconds, 0 = no scroll animation
          scroll_animation         : 'linear',  // supports 'swing' and 'linear', extend with jQuery UI.
          timer                    : 0,         // 0 = no timer , all other numbers = timer in milliseconds
          start_timer_on_click     : true,      // true or false - true requires clicking the first button start the timer
          start_offset             : 0,         // the index of the tooltip you want to start on (index of the li)
          next_button              : true,      // true or false to control whether a next button is used
          prev_button              : true,      // true or false to control whether a prev button is used
          tip_animation            : 'pop',    // 'pop' or 'fade' in each tip
          pause_after              : [],        // array of indexes where to pause the tour after
          exposed                  : [],        // array of expose elements
          tip_animation_fade_speed : 300,       // when tipAnimation = 'fade' this is speed in milliseconds for the transition
          cookie_monster           : true,     // true or false to control whether cookies are used
          cookie_name              : 'joyride', // Name the cookie you'll use
          cookie_domain            : false,     // Will this cookie be attached to a domain, ie. '.notableapp.com'
          cookie_expires           : 365,       // set when you would like the cookie to expire.
          tip_container            : 'body',    // Where will the tip be attached
          tip_location_patterns    : {
              top: ['bottom'],
              bottom: [], // bottom should not need to be repositioned
              left: ['right', 'top', 'bottom'],
              right: ['left', 'top', 'bottom']
          },
          post_ride_callback     : function (){},    // A method to call once the tour closes (canceled or complete)
          post_step_callback     : function (){},    // A method to call after each step
          pre_step_callback      : function (){},    // A method to call before each step
          pre_ride_callback      : function (){},    // A method to call before the tour starts (passed index, tip, and cloned exposed element)
          post_expose_callback   : function (){},    // A method to call after an element has been exposed
          template : { // HTML segments for tip layout
              link        : '<a href="#close" class="joyride-close-tip">&times;</a>',
              timer       : '<div class="joyride-timer-indicator-wrap"><span class="joyride-timer-indicator"></span></div>',
              tip         : '<div class="joyride-tip-guide"><span class="joyride-nub"></span></div>',
              wrapper     : '<div class="joyride-content-wrapper"></div>',
              button      : '<a href="#" class="small button joyride-next-tip"></a>',
              prev_button : '<a href="#" class="small button joyride-prev-tip"></a>',
              modal       : '<div class="joyride-modal-bg"></div>',
              expose      : '<div class="joyride-expose-wrapper"></div>',
              expose_cover: '<div class="joyride-expose-cover"></div>'
          },
          expose_add_class : '' // One or more space-separated class names to be added to exposed element
      }
  });
});

//= require turbolinks

$('document').ready(function() {
    $(".help").click(function() {
        $(document).foundation('joyride', 'start');
    });
});

