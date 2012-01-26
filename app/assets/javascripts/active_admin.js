//= require active_admin/base
//= require jquery.purr
//= require best_in_place
//= require tinymce-jquery
//= require chosen-jquery

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

  /*** Best In-Place ***/
  
  $('.best_in_place').best_in_place();

  /*** END ***/

  /*** TinyMCE ***/

  $('#mail_body').tinymce({
    theme: 'advanced',
    mode: 'textareas',
    plugins: 'noneditable'
  });

  $('.admin_criterion_mails').live('click', function() {
  	$('#mail_body').val(tinyMCE.activeEditor.getContent());
  });

  /*** END ***/

  /*** Chosen ***/

  $('.chosen-select').chosen();

  $('.button').live('click', function() {
		$('.chosen-select').chosen();
		$('.datepicker').datepicker();
  });

  /*** END ***/

  /*** Criterion Mailer ***/

  $('#mailer_all').live('click', function() {
    if($(this).is(':checked')) {
      $('input.mailer').each(function(index) {
        $(this).attr('checked', true);
      });
    } else {
      $('input.mailer').each(function(index) {
        $(this).attr('checked', false);
      });
    }
  });

  $('input.mailer').live('click', function() {
    if($(this).is(':checked')) {
      $('#mailer_all').attr('checked', true);
      $('input.mailer').each(function(index) {
        if(!$(this).is(':checked')) {
          $('#mailer_all').attr('checked', false);
        }
      });
    } else {
      $('#mailer_all').attr('checked', false);
    }
  });

  /*** END ***/
});