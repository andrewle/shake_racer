var maxValue = 100;
var racers = [
  {name: "Racer 1", score: 0},
  {name: "Racer 2", score: 0}
  ];
var registry = null;
var ws = null;

// keep track of the number of times the websocket has connected
var numTimesConnected = 0;

function debug(str) { };

function handleMessage(message) {
  switch(message.event) {
      case "update_scores":
        racers = message.racers;
        redraw();

        break;
      case "update":
        registry = message.registry;
        updateUpcomingRaces();

        break;
      case "countdown":
        countdown(message.count);

        break;
      case "new_match":
        newMatch(message);

        break;
      default:
        alert('Unknown event "' + message.event + '"');
  }
}

function countdown(count) {
  $('#curtain .countdown').html(count);
  if(count === 0) {
    $('#curtain').fadeTo(50, 0.0);
  }
}

function newMatch(message) {
  var team_names = message['match']['team_names'];

  $('#curtain').fadeTo(125, 1.0);
  $('#curtain .match').html(team_names[0] + ' VS ' + team_names[1]);
  countdown('');
}

function updateUpcomingRaces() {
  if(registry.matches.length === 0) {
    $('#upcoming-races').html('No upcoming races.');
    return;
  }

  $('#upcoming-races').html('');
  $(registry.matches).each(function(i) {
    $('#upcoming-races').append('<p>' + this.team_names[0] + ' VS ' + this.team_names[1] + '</p>');
  });
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
    var score = racers[i].score
    var fillPercentage = (score / maxValue) * 100;

    // update the racer's CSS
    fill.css('height', (100 - fillPercentage) + '%');

    // update the racer's name
    var selector = '#racer' + racerIdx + ' .name';
    $(selector).html(racers[i].name);
  }
}

function connect() {
  debug("connecting ...");

  var host = window.location.host;
  ws = new WebSocket("ws://" + host + "/ws");

  ws.onclose = function () {
    debug("socket closed");
    setTimeout('connect();', 1000);
  };

  ws.onopen = function () {
    debug("connected...");
    if(numTimesConnected++ > 0) {
        reload();
    }
  };

  ws.onmessage = function (evt) {
    //$("#msg").append("<p>" + evt.data + "</p>");
    handleMessage(JSON.parse(evt.data));
  };
}

function reload() {
    document.location = document.location.href;
}

$(function () {
    connect();
});
