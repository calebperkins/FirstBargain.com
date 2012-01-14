function poller(ids, details, prices) {
  var REFRESH_INTERVAL = 100;
  var POLL_INTERVAL = 750;
  var BUFFER_SIZE = 3;
  var TIMEOUT = 1350;
  var times = [];
  var responses = 0; // total good responses
  var avgoffset = 0;
  var cache, now, ticker;
  var last_poll = 0;

  // Constructor. Register all auctions.
  $(function () {
    $.each(ids, function (pos, id) {
      // Main info
      A[id] = {
        bidding: false
      };
      var a = A[id].$base = $("#auction_" + id);
      A[id].$going_price = $('.auction-price', a);
      A[id].$timer = $('.auction-timer', a);
      A[id].$bidder = $('.auction-last-bidder', a);
      A[id].$bid_button = $('.bid-button input', a);
      // Extra stuff for details page
      if (details) {
        A[id].$flash = $('.auction-flash-text', a);
        A[id].$total_price = $('.total-price .value', a);
        A[id].$percentage = $('.percentage', a);
        A[id].$bid_history = $("#bid-history tbody", a);
        A[id].$bid_bot_bids_left = $("#bid_bot_bids_left");
        // Buy Now highlights
        A[id].$bids_value = $('.highlight .credits-used .value', a);
        A[id].$buy_now_price = $('.highlight .buy-now-price .value', a);
        A[id].$credits_used = $('.highlight .credits-used-count', a);
        A[id].$bonuses_used = $('.highlight .bonuses-used-count', a);
      } else {
        A[id].retail_price = prices[id];
        A[id].$buy_now_price = $(".buy-now-price", a);
      }
    });
    details ? startOne() : startMany();
  });

  // Returns milliseconds in UTC
  function getNow() {
    var date = new Date();
    return date.getTime() + date.getTimezoneOffset() * 60000;
  }

  function fixTime() {
    return getNow() + avgoffset;
  }

  // Set the NTP offset.
  function setOffset(xhr) {
    var origtime = parseInt(xhr.getResponseHeader("NTP-Time"), 10);
    var offset = parseFloat(xhr.getResponseHeader("NTP-Offset"), 10);
    var delay = (getNow() - origtime) / 2;
    times[responses++ % BUFFER_SIZE] = offset - delay; // responses++ versus ++responses is important!
    var sum = 0;
    for (var i = 0; i < times.length; i++) {
      sum += times[i];
    }
    avgoffset = sum / times.length;
  }

  // Omit the last three parameters to highlight "current" without checking any equality.
  // Omit the last two parameters to highlight the supplied string without any special formatting functions.
  $.fn.highlight = function (current, cached, formatter, options) {
    var written = this.html(formatter ? formatter(current, options) : current);
    if (current !== cached) {
      return written.stop(true, true).effect("highlight", {color: "#fcd960"}, 3000);
    } else {
      return written;
    }
  };

  $.fn.setButton = function (json, cache) {
    if (json.u !== USER_LOGIN && !A[json.id].bidding) {
      this.css('background-position', '0 0').attr('disabled', false);
    } else if (json.u === USER_LOGIN && !A[json.id].bidding) {
      var offset = (SOURCE == "details") ? large_bid_complete : small_bid_complete;
      this.css('background-position', offset).attr('disabled', true);
    }
    return this;
  };

  $.fn.flash = function (msg, fadeOutTime) {
    return this.stop(true, true).show().html(msg).delay(1500).fadeOut(fadeOutTime);
  };

  function unregister(id) {
    delete A[id];
    /*if ($.isEmptyObject(A)) {
      clearInterval(ticker);
    }*/
  }

  $.fn.countdown = function (json) {
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
      display = '<span class="ending">' + sprintf("%02d:%02d:%02d", hours, minutes, seconds) + '</span>';
    } else {
      display = sprintf("%02d:%02d:%02d", hours, minutes, seconds);
    }
    return this.html(display);
  };

  // Use true as second parameter to append "(You!)"
  function formatBidder(name, withYou) {
    if (name == USER_LOGIN) {
      return "<strong>" + name + (withYou ? " (You!)" : "") + "</strong>";
    } else {
      return name;
    }
  }

  function formatPrice(price) {
    return '$' + Math.max(0, price).toFixed(2);
  }

  function formatPercentage(json) {
    return Math.max(0, Math.floor(100 * (1 - (json.p + json.investment.a) / RETAIL_PRICE))) + '%';
  }

  $.fn.bidHistory = function (json) {
    var s = "";
    $.each(json.bids, function (key, bid) {
      s += '<tr><td>' + formatBidder(bid.u, false) + '</td><td>' + formatPrice(bid.p) + '</td><td class=\'time\'>' + bid.t + '</td></tr>';
    });
    return this.html(s);
  };

  $.fn.bidFlash = function (json, cache) {
    var text = "";
    var nbid = json.n - cache.n;
    var remaining = json.e * 1000 - fixTime();
    if (nbid !== 0) {
      text += nbid + ((nbid == 1) ? ' Bid:' : ' Bids:');
      text += '&nbsp;&nbsp;&nbsp;&nbsp; Price +' + formatPrice(json.p - cache.p);
      if (remaining <= TIMER_RESET * 1000) {
        text += '&nbsp;&nbsp;&nbsp; Clock @' + TIMER_RESET + 'secs';
      }
    }
    return this.flash(text, 2500);
  };

  // Auction details page
  function startOne(id) {
    ticker = setInterval(tick, REFRESH_INTERVAL);

    function update(json, textStatus, xhr) {
      setOffset(xhr);
      if (!json.investment) {
        json.investment = {a: 0, b: 0, c: 0};
      }
      if (!cache) {
        cache = json;
      }
      var a = A[json.id];
      a.$timer.countdown(json);
      if (json.bot != null) { // may be 0, which would be false
        a.$bid_bot_bids_left.val(json.bot);
        if (json.bot == 0 && cache.bot > 0) {
          auctionDialog("Warning", "Your Bid Assistant is out of Bids.");
        };
      }
      if (json.account) {
        $(".credits-count").text(json.account.c); // todo: cache these jQuery objects
        $(".bonuses-count").text(json.account.b);
        if ((json.account.b + json.account.c == 0) && (cache.account.b + cache.account.c > 0)) {
          auctionDialog("Warning", "Your account is out of Bids. Please purchase more Bid Credits to continue bidding.");
        };
      };
      a.$going_price.highlight(json.p, cache.p, formatPrice);
      a.$bidder.highlight(json.u, cache.u, formatBidder, true);
      if (json.investment) {
        a.$bonuses_used.highlight(json.investment.b, cache.investment.b);
        a.$credits_used.highlight(json.investment.c, cache.investment.c);
        a.$bids_value.highlight(json.investment.a, cache.investment.a, formatPrice);
        a.$buy_now_price.highlight(RETAIL_PRICE - json.investment.a, RETAIL_PRICE - cache.investment.a, formatPrice);
        a.$total_price.highlight(json.investment.a + json.p, cache.investment.a + cache.p, formatPrice);
        a.$percentage.highlight(formatPercentage(json), formatPercentage(cache));
      }
      a.$bid_button.setButton(json, cache);
      if (json.n != cache.n) {
        a.$flash.bidFlash(json, cache);
      }
      a.$bid_history.bidHistory(json);
      if (json.done) { // End auction
        clearInterval(ticker);
        $('.auction-controls').hide();
        $('.auction-ended .credits-used-count').text(json.w.c);
        $('.auction-ended .credits-used .value').text(formatPrice(json.w.a));
        $('.auction-ended .total-paid .value').text(formatPrice(json.wp));
        $('.auction-ended .bonuses-used-count').text(json.w.b);
        $('.auction-ended .percentage').text(Math.max(0, Math.floor(100 * (1 - json.wp / RETAIL_PRICE))) + '%');
        $('.auction-ended').show();
        if (USER_LOGIN == json.u) {
          $('.winner-button').show();
        } else {
          $('.loser-button').show();
        }
        location.reload(true);
      }
      cache = json;
    }

    function auction_string() {
      for (var key in A) {
        if (A.hasOwnProperty(key)) {
          return key;
        }
      }
    }

    function tick() {
      now = getNow();
      if (now - last_poll >= POLL_INTERVAL) {
        $.ajax({
          url: '/poller/' + auction_string(),
          dataType: 'json',
          data: {u: USER_ID, t: now},
          success: update,
          timeout: TIMEOUT
        });
        last_poll = now;
      } else if (cache) {
        A[cache.id].$timer.countdown(cache);
      }
    }
  }

  // Watchlist, homepage, history page
  function startMany() {
    ticker = setInterval(tick, REFRESH_INTERVAL);

    function ids() {
      var s = "";
      $.each(A, function (id, val) {s += id + '-';});
      return s;
    }

    function update(json, textStatus, xhr) {
      setOffset(xhr);
      if (!cache) {
        cache = json;
      }
      if (json.bot != null) { // may be 0, which would be false
        a.$bid_bot_bids_left.val(json.bot);
        if (json.bot == 0 && cache.bot > 0) {
          auctionDialog("Warning", "Your Bid Assistant is out of Bids.");
        };
      }
      if (json.account) {
        $(".credits-count").text(json.account.c); // todo: cache these jQuery objects
        $(".bonuses-count").text(json.account.b);
        if ((json.account.b + json.account.c == 0) && (cache.account.b + cache.account.c > 0)) {
          auctionDialog("Warning", "Your account is out of Bids. Please purchase more Bid Credits to continue bidding.");
        };
      };
      for (var i = 0; i < json.auctions.length; i++) {
        var x = json.auctions[i];
        var y = cache.auctions[i];
        var a = A[x.id];
        if (!a) {
          continue;
        }
        a.$timer.countdown(x);
        a.$going_price.highlight(x.p, y.p, formatPrice);
        a.$bidder.highlight(x.u, y.u, formatBidder, false);
        a.$bid_button.setButton(x, y);
        if (x.investment) {
          a.$buy_now_price.text(formatPrice(a.retail_price - x.investment.a));
        }
        if (x.done) {
          unregister(x.id);
          $(".bid-button", a.$base).hide();
          $('.bidder-winner-label', a.$base).text("Winner:");
          if (USER_LOGIN === x.u) {
            $('.winner-button', a.$base).show();
            $('.timer-container .winner-text', a.$base).show();
            $('.timer-container .ended-text', a.$base).hide();
          } else {
            $('.loser-button', a.$base).show();
            $('.timer-container .winner-text', a.$base).hide();
            $('.timer-container .ended-text', a.$base).show();
          }
          $('.timer-container .auction-timer', a.$base).hide();
          $(a.$base).addClass('ended-trigger');
        }
      }
      cache = json;
    }

    function tick() {
      now = getNow();
      if (now - last_poll >= POLL_INTERVAL) {
        $.ajax({
          url: '/poller',
          dataType: 'json',
          data: {ids: ids(), t: now, u: USER_ID},
          success: update,
          timeout: TIMEOUT
        });
        last_poll = now;
      } else if (cache) {
        // Just update time
        for (var i = 0; i < cache.auctions.length; i++) {
          var info = cache.auctions[i];
          var a = A[info.id];
          if (!a) {continue;}
          a.$timer.countdown(info);
        }
      }
    }
  }

}