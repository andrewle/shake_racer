$(document).ready(function() {
  // TODO: this should likely be a scoped variable, leaving global for testing
  watchAccelerationId = null;

  var ws = null;

  var player = {
    hasJoinedTeam: false
  };

  if (!("WebSocket" in window)) {
    alert("Sorry, WebSockets unavailable.");
    return;
  }

  if (player.hasJoinedTeam === false) {
    window.location.hash = "#";
  }

  $("#join_team").submit(function (event) {
    event.preventDefault();
    window.location.hash = "#main_menu"
  });

  function connect() {
    var host = window.location.host;
    ws = new WebSocket("ws://" + host + "/ws");

    ws.onmessage = function (evt) {
    };

    ws.onclose = function () {
      alert("Alert connection to server lost.");
      setTimeout('connect()', 1000);
    };

    ws.onopen = function () {
      debug("connected...");
      if(numTimesConnected++ > 0) {
          reload();
      }
    };
  }

  $('#submit').click(function () {
    var nick = $('#nick').val();
    var msg = $('#message').val();

    ws.send(nick + ": " + msg);
    return false;
  });

  function startRaceAndroid() {
    watchAccelerationId = navigator.accelerometer.watchAcceleration(
      getAcceleration, accelerationError, {frequency: 40}
    );
  }

  function stopRaceAndroid() {
    if(watchAccelerationId) {
        navigator.acceleration.clearWatch(watchAccelerationId);
    }
  }

  function startRaceIphone() {
    window.ondevicemotion = function (event) {
      sendAcceleration(
        event.acceleration.x, event.acceleration.y, event.acceleration.z
      );
    }
  }

  function stopRaceIphone() {
    window.ondevicemotion = null;
  }

  function getAcceleration(acceleration) {
      sendAcceleration(acceleration.x, acceleration.y, acceleration.z);
  }

  function sendAcceleration(x, y, z) {
      var message = JSON.stringify({
        event: "shake",
        acceleration: [x, y, z]
      })

      debug(message);

      if(ws) {
        ws.send(message);
      }
  }

  // accelerationError: Failed to get the acceleration
  function accelerationError() {
      alert('Cannot race, error getting acceleration!');
  }

  if(navigator.userAgent.indexOf('Android')) {
    startRace = startRaceAndroid;
    stopRace = stopRaceAndroid;
  } else {
    startRace = startRaceIphone;
    stopRace = stopRaceIphone;
  }
});
