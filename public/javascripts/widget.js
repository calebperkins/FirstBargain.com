/*!
 * Javascript sprintf
 * http://www.webtoolkit.info/
 */
 
var sprintfWrapper = {
 
	init : function () {
 
		if (typeof arguments == "undefined") { return null; }
		if (arguments.length < 1) { return null; }
		if (typeof arguments[0] != "string") { return null; }
		if (typeof RegExp == "undefined") { return null; }
 
		var string = arguments[0];
		var exp = new RegExp(/(%([%]|(\-)?(\+|\x20)?(0)?(\d+)?(\.(\d)?)?([bcdfosxX])))/g);
		var matches = new Array();
		var strings = new Array();
		var convCount = 0;
		var stringPosStart = 0;
		var stringPosEnd = 0;
		var matchPosEnd = 0;
		var newString = '';
		var match = null;
 
		while (match = exp.exec(string)) {
			if (match[9]) { convCount += 1; }
 
			stringPosStart = matchPosEnd;
			stringPosEnd = exp.lastIndex - match[0].length;
			strings[strings.length] = string.substring(stringPosStart, stringPosEnd);
 
			matchPosEnd = exp.lastIndex;
			matches[matches.length] = {
				match: match[0],
				left: match[3] ? true : false,
				sign: match[4] || '',
				pad: match[5] || ' ',
				min: match[6] || 0,
				precision: match[8],
				code: match[9] || '%',
				negative: parseInt(arguments[convCount]) < 0 ? true : false,
				argument: String(arguments[convCount])
			};
		}
		strings[strings.length] = string.substring(matchPosEnd);
 
		if (matches.length == 0) { return string; }
		if ((arguments.length - 1) < convCount) { return null; }
 
		var code = null;
		var match = null;
		var i = null;
 
		for (i=0; i<matches.length; i++) {
 
			if (matches[i].code == '%') { substitution = '%' }
			else if (matches[i].code == 'b') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(2));
				substitution = sprintfWrapper.convert(matches[i], true);
			}
			else if (matches[i].code == 'c') {
				matches[i].argument = String(String.fromCharCode(parseInt(Math.abs(parseInt(matches[i].argument)))));
				substitution = sprintfWrapper.convert(matches[i], true);
			}
			else if (matches[i].code == 'd') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)));
				substitution = sprintfWrapper.convert(matches[i]);
			}
			else if (matches[i].code == 'f') {
				matches[i].argument = String(Math.abs(parseFloat(matches[i].argument)).toFixed(matches[i].precision ? matches[i].precision : 6));
				substitution = sprintfWrapper.convert(matches[i]);
			}
			else if (matches[i].code == 'o') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(8));
				substitution = sprintfWrapper.convert(matches[i]);
			}
			else if (matches[i].code == 's') {
				matches[i].argument = matches[i].argument.substring(0, matches[i].precision ? matches[i].precision : matches[i].argument.length)
				substitution = sprintfWrapper.convert(matches[i], true);
			}
			else if (matches[i].code == 'x') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
				substitution = sprintfWrapper.convert(matches[i]);
			}
			else if (matches[i].code == 'X') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
				substitution = sprintfWrapper.convert(matches[i]).toUpperCase();
			}
			else {
				substitution = matches[i].match;
			}
 
			newString += strings[i];
			newString += substitution;
 
		}
		newString += strings[i];
 
		return newString;
 
	},
 
	convert : function(match, nosign){
		if (nosign) {
			match.sign = '';
		} else {
			match.sign = match.negative ? '-' : match.sign;
		}
		var l = match.min - match.argument.length + 1 - match.sign.length;
		var pad = new Array(l < 0 ? 0 : l).join(match.pad);
		if (!match.left) {
			if (match.pad == "0" || nosign) {
				return match.sign + pad + match.argument;
			} else {
				return pad + match.sign + match.argument;
			}
		} else {
			if (match.pad == "0" || nosign) {
				return match.sign + match.argument + pad.replace(/0/g, ' ');
			} else {
				return match.sign + match.argument + pad;
			}
		}
	}
}


/*!
 * Copyright 2010 Expedient Shopping, Inc.
 * Not to be copied or distributed without the written consent of Expedient Shopping, Inc.
 */
function JustHaute(options) {
  var jQuery; // Localize jQuery variable
  var HOME = "http://www.firstbargain.com"; // without the trailing slash!
  var sprintf = sprintfWrapper.init;
  var times = [];
  var last_poll = 0, avgoffset = 0, responses = 0;
  var id, cache, ticker, $wrapper, $timer, $price, $bidder, products, num = 1;

  /******** Load jQuery if not present *********/
  if (window.jQuery === undefined || window.jQuery.fn.jquery !== '1.4.4') {
      var script_tag = document.createElement('script');
      script_tag.setAttribute("type","text/javascript");
      script_tag.setAttribute("src", "http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js");
      script_tag.onload = scriptLoadHandler;
      script_tag.onreadystatechange = function () { // Same thing but for IE
          if (this.readyState == 'complete' || this.readyState == 'loaded') {
              scriptLoadHandler();
          }
      };
      // Try to find the head, otherwise default to the documentElement
      (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);
  } else {
      // The jQuery version on the window is the one we want to use
      jQuery = window.jQuery;
      main();
  }

  /******** Called once jQuery has loaded ******/
  function scriptLoadHandler() {
    // Restore $ and window.jQuery to their previous values and store the
    // new jQuery in our local jQuery variable
    jQuery = window.jQuery.noConflict();
    // Call our main function
    main(); 
  }
  
  function getNow() {
    var date = new Date();
    return date.getTime() + date.getTimezoneOffset() * 60000;
  }

  function fixTime() {
    return getNow() + avgoffset;
  }
  
  function formatPrice(price) {
    return '$' + Math.max(0, price).toFixed(2);
  }
  
  // n is indexed at 1
  function loadProduct(n) {
    if (ticker) {
      clearInterval(ticker);
    }
    num = n;
    cache = products[n-1];
    id = cache.id;
    jQuery("#jh-num", $wrapper).text(n);
    jQuery(".jh-title h3", $wrapper).text(cache.name);
    jQuery(".jh-title del", $wrapper).text(formatPrice(cache.retail_price));
    jQuery(".jh-image img", $wrapper).attr("src", cache.picture);
    jQuery('.jh-auction-link', $wrapper).attr("href", auction_url(id));
    $bidder.text(cache.u);
    $price.text(formatPrice(cache.p));
    if (cache.prev_winner) {
      jQuery(".jh-previous-winner", $wrapper).text(cache.prev_winner);
      jQuery(".jh-previous-price", $wrapper).text(formatPrice(cache.prev_price));
      jQuery(".jh-previous-savings", $wrapper).text(cache.prev_savings);
    } else {
      jQuery(".jh-previous-auction", $wrapper).hide();
    }
    ticker = setInterval(tick, 100);
  }
  
  function initializeProducts(data) {
    products = data;
    jQuery("#jh-total", $wrapper).text(data.length);
    loadProduct(1);
  }
  
  function tick() {
    now = getNow();
    if (now - last_poll >= 1000) {
      jQuery.getJSON(HOME + "/promos/" + id + "?callback=?", {t: now}, update);
      last_poll = now;
    } else if (cache) {
      $timer.countdown(cache);
    }
  }
  
  function update(data) {
    setOffset(data);
    $timer.countdown(data);
    $price.highlight(data.p, cache.p, formatPrice);
    $bidder.highlight(data.u, cache.u);
    if (data.w) {
      clearInterval(ticker);
      jQuery(".jh-bid-button", $wrapper).hide();
      jQuery('.jh-loser-button', $wrapper).show();
      jQuery('.jh-ended-text', $wrapper).show();
      jQuery('.jh-auction-timer', $wrapper).hide();
    }
    cache = data;
  }
  
  // Set the NTP offset.
  function setOffset(data) {
    var origtime = data.nt;
    var offset = data.no;
    var delay = (getNow() - origtime) / 2;
    times[responses++ % 3] = offset - delay; // responses++ versus ++responses is important!
    var sum = 0;
    for (var i = 0; i < times.length; i++) {
      sum += times[i];
    }
    avgoffset = sum / times.length;
  }
  
  function auction_url(id) {
    var aff = (options.return_url ? options.return_url : HOME);
    var url = HOME + "/auctions/" + id + "?auction_registration=true&affiliate=" + options.affiliate + "&categories=" + options.auctionCategories.join("-") + "&affiliate_url=" + encodeURI(aff);
    return url;
  }
  
  function homepage_url() {
    var aff = (options.return_url ? options.return_url : HOME);
    return HOME + "?affiliate=" + options.affiliate + "&categories=" + options.auctionCategories.join("-") + "&affiliate_url=" + encodeURI(aff)
  }
  
  function main() {
    jQuery.getScript("https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.6/jquery-ui.min.js");
    // Set some utilities
    jQuery.fn.countdown = function (json) {
      var ms = json.e * 1000 - fixTime();
      var remaining = ms;
      var display;
      var hours = Math.floor(remaining / 3600000);
      remaining = remaining % 3600000;
      var minutes = Math.floor(remaining / 60000);
      remaining = remaining % 60000;
      var seconds = Math.ceil(remaining / 1000);
      if (seconds == 60) {
        seconds = 0;
        minutes++;
        if (minutes == 60) {
          minutes = 0;
          hours++;
        }
      }
      if (ms < 200) {
        display = "checking...";
      } else if (ms <= 15000) {
        display = '<span class="jh-ending">' + sprintf("%02d:%02d:%02d", hours, minutes, seconds) + '</span>';
      } else {
        display = sprintf("%02d:%02d:%02d", hours, minutes, seconds);
      }
      return this.html(display);
    };
    jQuery.fn.highlight = function (current, cached, formatter, options) {
      if (current !== cached) {
        this.html(formatter ? formatter(current, options) : current).stop(true, true).effect("highlight", {color: "#fcd960"}, 3000);
      }
      return this;
    };
    if (!options.widgetCategories) {
      options.widgetCategories = options.categories;
    }
    if (!options.auctionCategories) {
      options.auctionCategories = options.widgetCategories;
    }
    jQuery(function() {
      $wrapper = jQuery("#justhaute-widget-wrapper, .justhaute-widget-wrapper");
      $wrapper.append("" +
        "<div class='jh-nav'>" +
          "<div class='jh-paging'>" +
            "<a class='jh-prev' href='#'>&laquo; Prev</a>" +
            "<span id='jh-num'>1</span> of <span id='jh-total'>...</span>" +
            "<a class='jh-next' href='#'>Next &raquo;</a>" +
          "</div>" +
          "<a id='jh-all' href='" + homepage_url() + "'>View All</a>" +
        "</div>" +
        "<div class='jh-product-container'>" +
          "<div class='jh-title'>" +
            "<h3>loading...</h3>" +
            "<p>Reg. Price: <del>loading...</del></p>" +
          "</div>" +
          "<div class='jh-image'>" +
            "<a class='jh-auction-link' href='#'><img src='#'></a>" +
          "</div>" +
          "<div class='jh-timer-container'>" +
            "<div class='jh-auction-timer'>loading...</div>" +
            "<div class='jh-ended-text'>Ended!</div>" +
          "</div>" +
          "<div class='jh-price-container'>" +
            "<span class='jh-auction-price'>loading...</span>" +
          "</div>" +
          "<div class='jh-last-bidder-container'>" +
            "<span class='jh-auction-last-bidder'>loading...</span>" +
          "</div>" +
          "<div class='jh-buttons'>" +
            "<a class='jh-auction-link' href='#'><div class='jh-bid-button'></div></a>" + 
            "<a class='jh-auction-link' href='#'><div class='jh-loser-button'></div></a>" +
          "</div>" +
      "</div>" + 
      "<div class='jh-previous-auction'>" +
        "<div id='jh-savings-tag'><span class='jh-previous-savings'></span></div>" +
        "<p class='jh-previously-sold-for'>Previously sold to:</p>" +
        "<p><span class='jh-previous-winner'></span> for <span class='jh-previous-price'></span></p>" +
      "</div>");
      $timer = jQuery(".jh-auction-timer", $wrapper);
      $price = jQuery(".jh-auction-price", $wrapper);
      $bidder = jQuery(".jh-auction-last-bidder", $wrapper);
      jQuery(".jh-nav .jh-prev").click(function () {
        if (num > 1) {
          loadProduct(num - 1);
        }
        return false;
      });
      jQuery(".jh-nav .jh-next").click(function () {
        if (num < products.length) {
          loadProduct(num + 1);
        }
        return false;
      });
      jQuery.getJSON(HOME + "/promos?callback=?", {widgets: options.widgetCategories.join("-"), auctions: options.auctionCategories.join("-"), t: getNow()}, initializeProducts);
    });
  }
  
}