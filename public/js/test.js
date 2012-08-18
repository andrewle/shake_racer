function update() {
  var index = Math.random() < 0.5 ? 0 : 1;
  var newData = racers.slice(0);
  var interval = null;

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

function runTest() {
  interval = setInterval(function () {
    next();
  }, 50);
}

function testSetRegistry() {
    handleMessage(TEST_UPDATE_MESSAGE);
}

var TEST_UPDATE_MESSAGE = {
  "event": "Update",
  "registry": {
    "matches": [
      {
        "team_names": [
          "Team2",
          "Team1"
        ],
        "scores": [
          0,
          0
        ],
        "seconds_left": null
      }
    ],
    "teams": [
      {
        "name": "Team1"
      },
      {
        "name": "Team2"
      }
    ]
  }
}
