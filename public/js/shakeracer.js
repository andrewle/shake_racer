$(document).ready(function() {
  // TODO: this should likely be a scoped variable, leaving global for testing
  watchAccelerationId = null;

  var host = window.location.host;
  var ws = new WebSocket("ws://" + host + "/ws");

  ws.onmessage = function (evt) {
    var data = JSON.parse(evt.data);
    if (data.event === undefined) { return; }
    $('body').trigger(data.event, data);
  };

  ws.onclose = function () {
    alert("Alert connection to server lost.");
  };

  var player = new Player(ws);

  if (!("WebSocket" in window)) {
    alert("Sorry, WebSockets unavailable.");
    return;
  }

  if (player.hasJoinedTeam() === false) {
    window.location.hash = "#";
  }

  $("#join_team").submit(function (event) {
    event.preventDefault();
    player.register($('#team-name').val());
  });

  $('body').on('register_success', function (event, data) {
    window.location.hash = "#main_menu";
  });

  $('body').on('register_error', function (event, data) {
    alert(data.message);
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
