//= require active_admin/base
//= require jquery
//= require jquery_ujs
//= require jquery.purr
//= require best_in_place
//= require tinymce-jquery
//= require chosen-jquery
//= require fancybox

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
		$('.datepicker').datepicker({dateFormat: 'dd-mm-yy'});
  });

  /*** END ***/

  /*** Criterion Mailer && Criterion SMS Sender ***/

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

  /*** Criterion SMS ***/

  $('#criterion_sms_message').on('keyup', function() {
    var msg_length = $(this).val().length
    var str = msg_length.toString();
    str += ' / 240 characters';

    var counter = $(this).siblings('p.inline-hints');
    counter.text(str);

    var form = $(this).closest('form');
    if (msg_length > 240) {
      counter.addClass('red');
      form.find('input[type="submit"]').prop('disabled', true)
    } else {
      counter.removeClass('red');
      form.find('input[type="submit"]').prop('disabled', false)
    }
  });
  
  /*** END ***/

  /*** Internal Payments ***/

  if(!$('#payment_payment_method_2').is(':checked')) {
    $('#payment_other_account_input').hide();
  }
  
  // CASH
  $('#payment_payment_method_0').on('click', function(){
    $('#payment_other_account_input').hide();
    $('#payment_other_account').trigger("liszt:updated");
  });

  // CHEQUE
  $('#payment_payment_method_1').on('click', function(){
    $('#payment_other_account_input').hide();
    $('#payment_other_account').trigger("liszt:updated");
  });

  // INTERNAL
  $('#payment_payment_method_2').on('click', function(){
    $('#payment_other_account_input').show();
    $('#payment_other_account').trigger("liszt:updated");
  });

  /*** END ***/

  /*** FancyBox ***/

  $('a.fancybox').fancybox({
    'hideOnContentClick': false
  });

  /*** END ***/
});
