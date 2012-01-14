/*!
 * Copyright 2010 Expedient Shopping, Inc.
 * Not to be copied or distributed without the written consent of Expedient Shopping, Inc.
 */
var rollOvers = {};
var small_bid_complete = '0 -120px';
var large_bid_complete = '0 -150px';
var A = {}; // All auctions on page.

/* Product image rollovers */
function registerRollover(elem, img) {
  rollOvers[elem] = img;
}

function auctionDialog (_title, body) {
  $("#error-modal-dialog").text(body).dialog({ title: _title }).dialog('open');
	return false;
}

$(function() {
  // Internal variables
  var mouse_is_inside = false;
  var small_bidding = '0 -40px';
  var large_bidding = '0 -50px';
  var toDisable = '#shipping-address-toggle-node, #order_billing_address, #order_billing_address_2, #order_billing_city, #order_billing_state, #order_billing_zip, #order_billing_phone, #order_shipping_name, #order_shipping_address, #order_shipping_address_2, #order_shipping_city, #order_shipping_state, #order_shipping_zip, #order_shipping_phone';
  var latency = [0,0,0,0];
  var cur_l = 0;
  var start_t = 0;
  var $connStatus = $("#user-credits-main .latency");
  var connText = "";
  function updateConnStatus() {
    var avg_lat = (latency[0]+latency[1]+latency[2]+latency[3])/4;
    if(avg_lat < 300) {
      $connStatus.attr("class","latency conn-good");
      if(connText !== "good") {
        $connStatus.unbind("hover");
        connText = "good";
        $connStatus.tipTip({content: "Your internet connection is good"});
      }
    } else if(avg_lat < 700) {
      $connStatus.attr("class","latency conn-fair");
      if(connText !== "fair") {
        $connStatus.unbind("hover");
        connText = "fair";
        $connStatus.tipTip({content: "Your internet connection is fair"});
      }
    } else {
      $connStatus.attr("class","latency conn-poor");
      if(connText !== "poor") {
        $connStatus.unbind("hover");
        connText = "poor";
        $connStatus.tipTip({content: "Your internet connection is poor"});
      }
    }
  }
  $("body").ajaxSend(function (event, xhr, options) {
    start_t = new Date();
  });
  $("body").ajaxSuccess(function (event, xhr, options) {
    latency[(cur_l++)%4] = new Date().getTime() - start_t.getTime();
    updateConnStatus();
  });
  $("body").ajaxError(function (event, xhr, options, thrownError) {
    latency[(cur_l++)%4] = 2400;
    updateConnStatus();
    if (xhr.status == 503) { // System disruption
      window.location = "system/maintenance.html"
    }
  });
  
  // Hides and Removes "checked" property for Shipping Address checkbox -- Fix browser caching form inputs
  //$('#checkout-address #shipping-address').hide();
  $('#checkout-address #shipping-address-toggle-node').attr('checked', false);
  $(toDisable).attr('disabled', false);
  
  // Shipping Address Toggling
  $('#checkout-address #shipping-address-toggle-node').click(function () {
    $('#checkout-address #shipping-address').slideToggle('slow');
  });

  // Top Login Form Toggling
  $('#top-login #toggle-node').click(function(e){
    e.preventDefault();
    $('#top-login #login-body').toggle();
    $('#top-login #toggle-node').toggleClass('expanded');
  });
  $('#top-login #login-body').mouseup(function(){
    return false;
  });
  $(document).mouseup(function(e){
    if($(e.target).parent('#top-login #toggle-node').length==0){
      $('#top-login #toggle-node').removeClass('expanded');
      $('#top-login #login-body').hide();
    }
  });
  
  // IMAGE GALLERY
  $("#gallery li").mouseenter(function () {
    $('#viewer img').attr("src", rollOvers[$(this).attr('id')]);
  });

  // Payment Selection
  $('#cc-tab').click(function () {
    $(this).addClass('selected');
    $('#pp-tab').removeClass('selected');
    $('#credit-card-form').stop(true, true).show();
    $('#paypal-form').stop(true, true).hide();
    $(toDisable).attr('disabled', false);
    $("#order_gateway").val("authorize");
  });
  $('#pp-tab').click(function () {
    $(this).addClass('selected');
    $('#cc-tab').removeClass('selected');
    $('#paypal-form').stop(true, true).show();
    $('#credit-card-form').stop(true, true).hide();
    $(toDisable).attr('disabled', 'disabled');
    $('#order_gateway').val("paypal");
  });

  // Binds AJAX bid clicks
  $('#main-auctions form, #watchlist-auctions form').bind("ajax:before", function () {
    A[parseInt(this.id, 10)].bidding = true;
    $(this.commit).css('background-position', small_bidding).attr('disabled', 'disabled');
  });
  $('#main-numbers form').bind("ajax:before", function () {
    A[parseInt(this.id, 10)].bidding = true;
    $(this.commit).css('background-position', large_bidding).attr('disabled', 'disabled');
  });

  // Invitation Page Tabs
  $('#invite-friends-tab').click(function () {
    $(this).addClass('selected');
    $('#your-invites-tab').removeClass('selected');
    $('#invite-friends').stop(true, true).show();
    $('#your-invites').stop(true, true).hide();
  });
  $('#your-invites-tab').click(function () {
    $(this).addClass('selected');
    $('#invite-friends-tab').removeClass('selected');
    $('#your-invites').stop(true, true).show();
    $('#invite-friends').stop(true, true).hide();
  });

  // FAQ toggle
  $(".faq-block h3").click(function() {
    var block = $(this).parent();
    if (block.hasClass("faq-hidden")) {
      block.removeClass("faq-hidden");
    } else {
      block.addClass("faq-hidden");
    }
  });
  // FAQ Hover Effects
  $("#faq-page-index .column").hover(function() {
    var button = $(this).children(":first");
    button.addClass("revealed");
  },
  function () {
    var button = $(this).children(":first");
    button.removeClass("revealed");
  });

  // POP UPS
  $('a.popup').live('click', function(){
    newwindow = window.open($(this).attr('href'),'','height=400,width=600,scrollbars=yes,left=200,top=50');
    if (window.focus) { newwindow.focus(); }
    return false;
  });

  // BUY NOW AND ERROR CLOSE
  $('.overlay-popup-toggle').click(function() {
    $(this).parent().hide();
  });

  // tipTip trigger
  $(".hasTooltip").tipTip({maxWidth: "270px"});
  
  // Orders History Table Toggle
  $("#show-void-declined").click(function() {
    var wrap = $(this).parent();
    var tab = wrap.children(":first");
    if (tab.hasClass("order-history-hidden")) {
      tab.removeClass("order-history-hidden");
      $(this).text("Hide Void & Declined Orders");
    } else {
      tab.addClass("order-history-hidden");
      $(this).text("Show Void & Declined Orders");
    }
  });

  // Order confirmation screen
  $("#place-order form").bind("ajax:before", function () {
    $("#place-order").hide();
    $("#order-processing").show();
  });

	// Initialize Modal Dialogs
	$("#error-modal-dialog").dialog({
		width: 400,
		draggable: false,
		closeOnEscape: true,
		dialogClass: 'error-modal-dialog',
		autoOpen: false,
		resizable: false, 
		modal: true,
		buttons:{ "Close": function() { $(this).dialog('close'); } }
	});

}); // closes doc ready function