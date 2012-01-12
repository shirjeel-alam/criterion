// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

function remove_fields(link, field) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(field).fadeOut(function(){
    $(this).remove();
  });
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(link).before(content.replace(regexp, new_id)).hide().fadeIn();
}

function test() {
  console.log('Here');
  alert("Hello!");
}

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
});