(function () {
  var Player = window.Player = function (connection) {
    this.connection = connection;
    this.teamName = "";
  };

  Player.prototype = {
    hasJoinedTeam: function () {
      return this.teamName !== null && this.teamName !== undefined &&
        this.teamName !== "";
    },

    register: function (teamName) {
      var data = {
        event: "register",
        team: teamName
      };
      this.teamName = teamName;
      this.connection.send(JSON.stringify(data));
    }
  }
})();
