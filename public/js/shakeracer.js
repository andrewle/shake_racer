function debug(str) { };

$(document).ready(function() {
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
  ws.onmessage = function (evt) { $("#msg").append("<p>" + evt.data + "</p>"); };
  ws.onclose = function () { debug("socket closed"); };
  ws.onopen = function () { debug("connected..."); };

  $('#submit').click(function () {
    var nick = $('#nick').val();
    var msg = $('#message').val();

    ws.send(nick + ": " + msg);
    return false;
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
