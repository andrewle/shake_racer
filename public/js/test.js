function update() {
  var index = Math.random() < 0.5 ? 0 : 1;
  var newData = racers.slice(0);

  newData[index].score += parseInt(Math.random() * 5);
  newData[index].score = Array.min([maxValue, newData[index].score]);

  handleMessage({racers: newData});
}

function next() {
  update();
  redraw();

  var i=0;
  for(i=0; i<racers.length; i++) {
    if(racers[i].score >= maxValue) {
      clearInterval(interval);
      break;
    }
  }
}

var interval = setInterval(function () {
  next();
}, 50);
