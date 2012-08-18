$(document).ready(function() {
  // TODO: this should likely be a scoped variable, leaving global for testing
  watchAccelerationId = null;

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

  var host = window.location.host;
  var ws = new WebSocket("ws://" + host + "/ws");

  ws.onmessage = function (evt) {
  };

  ws.onclose = function () {
    alert("Alert connection to server lost.");
  };

  $('#submit').click(function () {
    var nick = $('#nick').val();
    var msg = $('#message').val();

    ws.send(nick + ": " + msg);
    return false;
  });

  function debug(str) { }

  function startRace() {
    watchAccelerationId = navigator.accelerometer.watchAcceleration(
      getAcceleration, accelerationError, {frequency: 40}
    );
  }

  function stopRace() {
    if(watchAccelerationId) {
        navigator.acceleration.clearWatch(watchAccelerationId);
    }
  }

  function getAcceleration(acceleration) {
      debug('Acceleration X: ' + acceleration.x + '\n' +
            'Acceleration Y: ' + acceleration.y + '\n' +
            'Acceleration Z: ' + acceleration.z + '\n' +
            'Timestamp: '      + acceleration.timestamp + '\n');

      var message = JSON.stringify({
        event: "shake",
        acceleration: [acceleration.x, acceleration.y, acceleration.z]
      })

      if(ws) {
        ws.send(message);
      }
  }

  // accelerationError: Failed to get the acceleration
  function accelerationError() {
      alert('Cannot race, error getting acceleration!');
  }
});
