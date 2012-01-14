jQuery.fn.slideshow = function() {
  var settings = {
    fadetime: 1200,
    timeout: 8000
  };
  var current = 1, last = 0, timer = '';
  
  var change = function () {
  for (var i = 0; i < slides.length; i++) {
    jQuery(slides[i]).css('display', 'none');
  }
  jQuery(slides[last]).css('display', 'block').css('zIndex', '0');
  
  jQuery(slides[current]).css('zIndex', '1').fadeIn(settings.fadetime);

  if ( ( current + 1 ) < slides.length ) {
    current = current + 1;
    last = current - 1;
  } else {
    current = 0;
    last = slides.length - 1;
  }
  timer = setTimeout(change, settings.timeout);
  };
  var slides = this.find('div').get();
  jQuery.each(slides, function(i){
    jQuery(slides[i]).css('zIndex', slides.length - i);
  });
  
  timer = setTimeout(change, settings.timeout);

  // pause on hover
  $('#slideshow div.image-map').hover(function(){
    clearTimeout(timer);
  },function(){
    timer = setTimeout(change, settings.timeout);
  });
  return this;
};

$(document).ready(function() {
  // INITIATE SLIDESHOW
  $('#slideshow').slideshow();
});