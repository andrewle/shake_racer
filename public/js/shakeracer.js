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
