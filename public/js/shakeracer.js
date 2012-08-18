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

  $('body').on('update', function (event, data) {
    console.log(data);
  });

  $('body').on("countdown", function(event, data) {
    // when the count is 0, grab all motion
    if(data.count === 0) {
      window.ondevicemotion = function (event) {
        var message = JSON.stringify({
          x: event.acceleration.x,
          y: event.acceleration.y,
          z: event.acceleration.z
        });

        ws.send(message);
      }
    }
  });

  $('body').on("new_match", function(event, data) {
    window.ondevicemotion = null;
  });
});
