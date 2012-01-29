// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function() {

	/*** Payment Tables ***/

  $(".content").hide();
  $(".header").live('click', function()
  {
    image = $(this).children('td:first').children('img')
    if ($(image).attr('alt') == 'Down_arrow') {
      $(image).attr('alt', 'Up_arrow');
      $(image).attr('src', '/assets/up_arrow.png');
    } else {
      $(image).attr('alt', 'Down_arrow');
      $(image).attr('src', '/assets/down_arrow.png');
    }
    $(this).nextUntil(".header").toggle();
  });

  /*** END ***/
  
});