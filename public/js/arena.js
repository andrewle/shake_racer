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
      case "match_ended":
        matchEnded(message);

        break;
      default:
        console.log('Unknown event "' + message.event + '"');
  }
}

function matchEnded(message) {
    var fill = $('#racer' + 1 + ' .fill');
    x0 = parseInt(fill.css('height'));

    var fill = $('#racer' + 2 + ' .fill');
    x1 = parseInt(fill.css('height'));

    console.log(x0 + ' , ' + x1);

    if(x0 > x1) {
        var winner = "blue";
    } else {
        var winner = "red";
    }

    $('#banner').html(winner + ' wins!');
    $('#banner').show();
}

function countdown(count) {
  $('#curtain .countdown').html(count);
  if(count === 0) {
    $('#curtain').fadeTo(50, 0.0);
  }
}

function newMatch(message) {
  var team_names = message['match']['team_names'];

  $('#banner').hide();
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

    if(fillPercentage >= 100) {
        $('#banner').html(racers[i]);
        $('#banner').show();
    }

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
