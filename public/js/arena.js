var maxValue = 100;
var racers = [0, 0];

function debug(str) { };

function handleMessage(message) {
  if(message.racers) {
    racers = message.racers;
    redraw();
  }
}

/**
 * Redraw the racer bars based on the racers array.
 *
 * The racers array holds the racers' progress.  The bar will be filled relative
 * to the value in the array.
 */
function redraw() {
  var i;

  for(i = 0; i < racers.length; i++) {
    var racerIdx = i+1;
    var selector = '#racer' + racerIdx + ' .fill';
    var fill = $(selector);

    // how full the container should be
    var fillPercentage = (racers[i] / maxValue) * 100;

    // the percentage from the top of the container div the fill container should be
    var topPercentage = 100 - fillPercentage;

    // update the racer's CSS
    fill.css('height', fillPercentage + '%');
    fill.css('top', topPercentage + '%');
  }
}

$(function () {
  var host = window.location.host;
  var ws = new WebSocket("ws://" + host + "/ws");

  ws.onclose = function () { debug("socket closed"); };
  ws.onopen = function () { debug("connected..."); };

  ws.onmessage = function (evt) {
    $("#msg").append("<p>" + evt.data + "</p>");
    handleMessage(JSON.parse(evt.data));
  };
});
