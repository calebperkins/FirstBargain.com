$(function() {
  $('#home-tab').click(function () {
    $(this).addClass('selected');
    $('#contact-tab').removeClass('selected');
    $('#home-page').stop(true, true).show();
    $('#contact-page').stop(true, true).hide();
  });
  $('#contact-tab').click(function () {
    $(this).addClass('selected');
    $('#home-tab').removeClass('selected');
    $('#contact-page').stop(true, true).show();
    $('#home-page').stop(true, true).hide();
  });
  $('#contact-link').click(function () {
    $('#contact-tab').addClass('selected');
    $('#home-tab').removeClass('selected');
    $('#contact-page').stop(true, true).show();
    $('#home-page').stop(true, true).hide();
  });
});