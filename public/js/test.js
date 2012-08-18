function update() {
  var index = Math.random() < 0.5 ? 0 : 1;
  var newData = racers.slice(0);

  newData[index] += parseInt(Math.random() * 5);
  newData[index] = Array.min([maxValue, newData[index]]);

  handleMessage({racers: newData});
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
