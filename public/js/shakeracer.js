function debug(str)
{
  $("#debug").append("<p>" + str + "</p>");
};

$(document).ready(function()
{
  if (!("WebSocket" in window))
  {
    alert("Sorry, WebSockets unavailable.");
    return;
  }

  var ws = new WebSocket("ws://localhost:9000/ws");
  ws.onmessage = function(evt) { $("#msg").append("<p>" + evt.data + "</p>"); };
  ws.onclose = function() { debug("socket closed"); };
  ws.onopen = function() { debug("connected..."); };

  $('#submit').click(function()
  {
    var nick = $('#nick').val();
    var msg = $('#message').val();

    ws.send(nick + ": " + msg);
    return false;
  });

  window.ondevicemotion = function(event)
  {
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
