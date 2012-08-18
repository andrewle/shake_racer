$(document).ready(function() {
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

  window.ondevicemotion = function (event) {
    return;
    // nothing to do if there websocket is not connected
    if(!ws) { return; }

    var message = JSON.stringify({
      x: event.acceleration.x,
      y: event.acceleration.y,
      z: event.acceleration.z
    });

    ws.send(message);
  }
});
