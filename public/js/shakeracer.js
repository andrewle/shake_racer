$(document).ready(function() {
  var host = window.location.host;
  var ws = new WebSocket("ws://" + host + "/" + endpoint);

  ws.onmessage = function (evt) {
    var data = JSON.parse(evt.data);
    if (data.event === undefined) { return; }
    $('body').trigger(data.event, data);
  };

  ws.onclose = function () {
    alert("Alert connection to server lost.");
  };

  if (!("WebSocket" in window)) {
    alert("Sorry, WebSockets unavailable.");
    return;
  }

  $('body').on("countdown", function(event, data) {
    if (data.count > 0) {
      $("#the_match h1").html(data.count);
    } else {
      $("#the_match h1").html("SHAKE IT");
    }
  });

  var inMotion = false;

  window.ondevicemotion = function (evt) {
    if (inMotion === false) { return; }
    var message = JSON.stringify({
      event: "shake",
      team: endpoint,
      acceleration: [evt.acceleration.x, evt.acceleration.y, evt.acceleration.z]
    });

    ws.send(message);
  }

  $('body').on("match_ended", function(event, data) {
    alert("Game, set, and match!");
    window.location.pathname = "/index.html";
  });

  $('body').on("countdown", function(event, data) {
    // when the count is 0, grab all motion
    if(data.count === 0) {
      inMotion = true;
    }
  });

  $('body').on("new_match", function(event, data) {
    inMotion = false;
  });
});
