//= require active_admin/base
//= require jquery
//= require jquery_ujs
//= require jquery.purr
//= require best_in_place
//= require chosen-jquery
//= require fancybox
//= require moment

$(document).ready(function() {

  /*** Payment Tables ***/

  $(".content").hide();
  $(".nested_header").siblings(".header").hide();

  $(".header").on('click', function()
  {
    arrow_wrapper = $(this).children('td:first')
    if ($(arrow_wrapper).hasClass('down')) {
      $(arrow_wrapper).removeClass('down');
      $(arrow_wrapper).addClass('up');
    } else {
      $(arrow_wrapper).removeClass('up');
      $(arrow_wrapper).addClass('down');
    }
    $(this).nextUntil(".header").toggle();
  });

  $(".nested_header").on('click', function()
  {
    arrow_wrapper = $(this).children('td:first')
    if ($(arrow_wrapper).hasClass('down')) {
      $(arrow_wrapper).removeClass('down');
      $(arrow_wrapper).addClass('up');
    } else {
      $(arrow_wrapper).removeClass('up');
      $(arrow_wrapper).addClass('down');
    }
    $(this).nextUntil(".nested_header").toggle();
    $(".content").hide();
  });

  /*** END ***/

  /*** Best In-Place ***/
  
  $('.best_in_place').best_in_place();

  /*** END ***/

  /*** Chosen ***/

  $('.chosen-select').chosen();
  $('.chosen-select-deselect').chosen({allow_single_deselect: true});

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
    'hideOnContentClick': false,
    'scrolling' : 'no',
    'autoScale' : false,
    'autoDimensions' : false,
    onComplete       : function() {
      $('.chosen-select-modal').chosen();
    }
  });

  /*** END ***/

  /*** Current Date and Time ***/

  setInterval(function() {
    updateTime();  
  }, 1000);

  $('#titlebar_right').prepend("<h3></h3>");
  updateTime();

  /*** END ***/

  /*** Menu Ordering ***/

  $('#criterion').swap($('#more_menus'));  
  $('#account_actions').swap($('#criterion'));

  /*** END ***/
});

function updateTime() {
  var currentTime = moment().format('dddd, MMMM Do YYYY, h:mm:ss a');
  $('#titlebar_right > h3').html(currentTime);
}

jQuery.fn.swap = function(b){
  b = jQuery(b)[0];
  var a = this[0];
  var t = a.parentNode.insertBefore(document.createTextNode(''), a);
  b.parentNode.insertBefore(a, b);
  t.parentNode.insertBefore(b, t);
  t.parentNode.removeChild(t);
  return this;
};
