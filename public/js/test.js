function update() {
  var index = Math.random() < 0.5 ? 0 : 1;

  data[index] += parseInt(Math.random() * 5);
  data[index] = Array.min([maxValue, data[index]]);
}

function next() {
  update();
  redraw();

  if(Array.max(racers) >= maxValue) {
    clearInterval(interval);
  }
}

var interval = setInterval(function () {
  next();
}, 50);
