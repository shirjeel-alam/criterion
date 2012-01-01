//= require active_admin/base
//= require jquery.purr
//= require best_in_place

$(document).ready(function() {
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

  $(".best_in_place").best_in_place();
});