function SpreeDeliveryDate() {
  var that = this;

  this.initializeDatePicker = function() {
    $('#order_delivery_date').datepicker({
      dateFormat: "dd/mm/yy",
      minDate: 1,
      beforeShowDay: function(date) {
        var day = date.getDay();
        return [(day != 0 && day != 1), ''];
      }
    });
  };
}

$(document).ready(function() {
  var deliveryDate = new SpreeDeliveryDate();
  deliveryDate.initializeDatePicker();
});
