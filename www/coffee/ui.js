// Generated by CoffeeScript 1.3.3
(function() {
  var ui;

  window.BEATmatic = {};

  ui = (function() {

    function ui() {
      var _this = this;
      $(".gotoMain").click(function() {
        return _this["switch"]("main");
      });
      $(".gotoShare").click(function() {
        return _this["switch"]("share");
      });
    }

    ui.prototype["switch"] = function(tabid) {
      var jtab, tab, _i, _len, _ref;
      _ref = $("#ui").children();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tab = _ref[_i];
        jtab = $(tab);
        if (tab.id === tabid) {
          jtab.show();
        } else {
          jtab.hide();
        }
      }
      if (tab === "dj") {
        return BEATmatic.sequencer.resetButtons();
      }
    };

    return ui;

  })();

  $(function() {
    return BEATmatic.ui = new ui();
  });

}).call(this);
