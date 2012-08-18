var maxValue = 100;
var data = [0, 0];

/**
 * Redraw the racer bars based on the data array.
 *
 * The data array holds the racers' progress.  The bar will be filled relative
 * to the value in the array.
 */
function redraw() {
  var i;

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
