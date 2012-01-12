//= require active_admin/base
//= require jquery.purr
//= require best_in_place
//= require tinymce-jquery

$(document).ready(function() {
  $('.best_in_place').best_in_place();

  $('#mail_body').tinymce({
    theme: 'advanced'
  });

  $('.admin_mails').live('click', function() {
  	$('#mail_body').val(tinyMCE.activeEditor.getContent());
  });
});