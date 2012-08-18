Array.max = function( array ){
  return Math.max.apply( Math, array );
};

Array.min = function( array ){
  return Math.min.apply( Math, array );
};

var maxValue = 100;
var data = [0, 0];

function update() {
  var index = Math.random() < 0.5 ? 0 : 1;

  data[index] += parseInt(Math.random() * 5);
  data[index] = Array.min([maxValue, data[index]]);
}

function redraw() {
  var i;
  console.log(data);
  for(i = 0; i < data.length; i++) {
    var racerIdx = i+1;
    var selector = '#racer' + racerIdx + ' .fill';
    var fill = $(selector);

    // how full the container should be
    var fillPercentage = (data[i] / maxValue) * 100;

    // the percentage from the top of the container div the fill container should be
    var topPercentage = 100 - fillPercentage;

    // update the racer's CSS
    fill.css('height', fillPercentage + '%');
    fill.css('top', topPercentage + '%');
  }
}

function next() {
  update();
  redraw();

  if(Array.max(data) >= maxValue) {
    clearInterval(interval);
  }
}

var interval = setInterval(function () {
  next();
}, 50);
