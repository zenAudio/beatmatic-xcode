// Generated by CoffeeScript 1.3.3
(function() {
  var play,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  play = (function() {

    play.prototype.loopTimers = {};

    play.prototype.swipeSampleLayover = false;

    play.prototype.swipeVolumeLayover = false;

    play.prototype.lastSample = false;

    play.prototype.originalbpm = false;

    play.prototype.direction = false;

    play.prototype.lastDistance = 0;

    function play() {
      this.generateHTML = __bind(this.generateHTML, this);

      this.setup = __bind(this.setup, this);

      var _this = this;
      $("#snext").click(function() {
        BEATmatic.ui["switch"]("dj");
        BEATmatic.sequencer.highlightPlayer = false;
        return false;
      });
      $("#sback").click(function() {
        BEATmatic.sequencer.stopCoreLoop();
        BEATmatic.ui["switch"]("main");
        BEATmatic.sequencer.highlightPlayer = false;
        return false;
      });
    }

    play.prototype.setup = function(data) {
      if (data === "demo") {
        BEATmatic.sequencer.setup({
          "project": "House Beat 1",
          "bpm": 130,
          "tracks": [
            {
              "name": "kick drum",
              "sample": "kick01.wav",
              "icon": "kickdrum.png",
              "score": [100, 0, 0, 0, 0, 0, 0, 100, 100, 0, 0, 0, 0, 0, 0, 0]
            }, {
              "name": "snare drum",
              "sample": "snare01.wav",
              "icon": "snaredrum.png",
              "score": [0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0, 0]
            }, {
              "name": "hi hat",
              "sample": "hihat01.wav",
              "icon": "hihat.png",
              "score": [0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0, 0, 0, 100, 0]
            }
          ]
        });
      } else {
        BEATmatic.sequencer.setup(data);
      }
      this.generateHTML();
      return BEATmatic.sequencer.highlightPlayer = true;
    };

    play.prototype.generateHTML = function() {
      var html, index, score, track, _i, _j, _len, _len1, _ref, _ref1,
        _this = this;
      html = "<table id=\"hor-minimalist-a\" class=\"fulltable\" summary=\"Matrix\">";
      _ref = BEATmatic.sequencer.drumTracks.tracks;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        track = _ref[index];
        html += "<tr>";
        html += "<td class=\"\"><img width=\"50\" height=\"50\" src=\"img/" + track.icon + "\" alt=\"" + track.name + "\"/></td>";
        _ref1 = track.score;
        for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
          score = _ref1[index];
          if (score >= 100) {
            score = 100;
          }
          html += "<td class=\"x" + score + " c" + (index + 1) + "\"></td>";
        }
        html += "</tr>";
      }
      html += "</table>";
      $("#matrix").html(html);
      return $("#hor-minimalist-a").swipe({
        click: function(e, target) {
          var cell;
          score = e.target.cellIndex;
          track = e.target.parentNode.rowIndex;
          cell = $($(".c" + score)[track]);
          if (cell.hasClass("x100")) {
            cell.removeClass("x100");
            return BEATmatic.sequencer.drumTracks.tracks[track].score[score - 1] = 0;
          } else {
            cell.addClass("x100");
            return BEATmatic.sequencer.drumTracks.tracks[track].score[score - 1] = 100;
          }
        },
        swipeStatus: function(e, phase, direction, distance) {
          var i, move, n, newsample, offset, sample;
          if (phase === "cancel" || phase === "end") {
            _this.direction = false;
            _this.lastDistance = 0;
            if (_this.swipeSampleLayover) {
              $("#swipeSampleLayover").hide();
              _this.swipeSampleLayover = false;
              BEATmatic.sequencer.stopCoreLoop();
              BEATmatic.sequencer.startCoreLoop();
            }
            if (_this.swipeVolumeLayover) {
              $("#swipeVolumeLayover").hide();
              _this.originalbpm = false;
              _this.swipeVolumeLayover = false;
            }
            return;
          }
          if (distance <= 5) {
            return;
          }
          if (direction === "up" || direction === "down") {
            if (!_this.direction) {
              _this.direction = "updown";
            }
            if ("updown" !== _this.direction) {
              return;
            }
            if (!_this.swipeSampleLayover) {
              BEATmatic.sequencer.stopCoreLoop();
              _this.swipeSampleLayover = true;
              $("#swipeSampleLayover").show();
              _this.samplebase = false;
            }
            if (_this.lastUpDownDirection !== direction) {
              _this.lastDistance = distance;
              _this.lastUpDownDirection = direction;
            }
            move = distance - _this.lastDistance;
            if ((move < 10) && (move > -10)) {
              return;
            }
            _this.lastDistance = distance;
            track = e.target.parentNode.rowIndex;
            sample = BEATmatic.sequencer.drumTracks.tracks[track].sample;
            i = sample.indexOf("0");
            n = Number(sample[i + 1]);
            if (!_this.samplebase) {
              _this.samplebase = sample.slice(0, i);
            }
            if (direction === "up") {
              if (!(n >= 7)) {
                n++;
              }
            }
            if (direction === "down") {
              if (!(n <= 1)) {
                n--;
              }
            }
            newsample = _this.samplebase + 0 + n + sample.slice(i + 2);
            BEATmatic.sequencer.playAudio(BEATmatic.sequencer.folder + "drums/" + newsample);
            BEATmatic.sequencer.drumTracks.tracks[track].sample = newsample;
            $("#swipeSampleLayover").html(newsample);
          }
          if (direction === "left" || direction === "right") {
            if (!_this.direction) {
              _this.direction = "leftright";
            }
            if ("leftright" !== _this.direction) {
              return;
            }
            if (!_this.swipeVolumeLayover) {
              $("#swipeVolumeLayover").show();
              _this.swipeVolumeLayover = true;
            }
            offset = Math.round(distance / 2);
            if (direction === "left") {
              offset = offset * -1;
            }
            if (!_this.originalbpm) {
              _this.originalbpm = BEATmatic.sequencer.BPM;
            }
            $("#swipeVolumeLayover").html("" + (_this.originalbpm + offset) + " BPM");
            BEATmatic.sequencer.changeBPM(_this.originalbpm + offset);
          }
        },
        allowPageScroll: "none",
        threshold: 50
      });
    };

    play.prototype.highlightColumn = function(col) {
      $(".c" + col).addClass("highlighted");
      col = col - 1;
      if (col === 0) {
        col = 16;
      }
      return $(".c" + col).removeClass("highlighted");
    };

    return play;

  })();

  $(function() {
    return BEATmatic.play = new play();
  });

}).call(this);
