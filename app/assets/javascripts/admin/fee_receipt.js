var FeeReceiptForm = {
  initialize: function() {
    $('input.payment[type=checkbox]').on('click', function() {
      if ($(this).is(':checked')) {
        FeeReceiptForm.addToTotal($(this));
      } else {
        FeeReceiptForm.removeFromTotal($(this));
      }
    });

    $('input.payment[type=checkbox]').attr('checked', false);
  },
  addToTotal: function(checkbox) {
    var gross_amount = parseInt($(checkbox).parent().siblings('.gross_amount').data('value'));
    var discount = parseInt($(checkbox).parent().siblings('.discount').data('value'));
    
    if(!isNaN(gross_amount))
      $('#total-gross-amount').text(parseInt($('#total-gross-amount').text()) + gross_amount);
    if(!isNaN(discount))
      $('#total-discount').text(parseInt($('#total-discount').text()) + discount);

    FeeReceiptForm.updateValues();
  },
  removeFromTotal: function(checkbox) {
    var gross_amount = parseInt($(checkbox).parent().siblings('.gross_amount').data('value'));
    var discount = parseInt($(checkbox).parent().siblings('.discount').data('value'));
    
    if(!isNaN(gross_amount))
      $('#total-gross-amount').text(parseInt($('#total-gross-amount').text()) - gross_amount);
    if(!isNaN(discount))
      $('#total-discount').text(parseInt($('#total-discount').text()) - discount);
    
    FeeReceiptForm.updateValues();
  },
  updateValues: function() {
    var gross_amount = parseInt($('#total-gross-amount').text());
    var discount = parseInt($('#total-discount').text());
    var net_amount = gross_amount - discount;
    var amountReceived = parseInt($('#amount-received').text());
    var change = amountReceived - net_amount;
    $('#total-net-amount').text(net_amount);
    if(change > 0)
      $('#change').text(change);
  }
};

if ('undefined' !== typeof Turbolinks) {
  $(document).on('page:change', FeeReceiptForm.initialize);
} else {
  $(document).ready(FeeReceiptForm.initialize);
}