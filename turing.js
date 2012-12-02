// Generated by CoffeeScript 1.3.1
(function() {
  var State, StateMachine, init, list, shiftTapeLeft, shiftTapeRight, shiftTapeStep, symbols;

  symbols = list = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'];

  State = (function() {

    State.name = 'State';

    function State(actions, nextState) {
      this.actions = actions;
      this.nextState = nextState;
    }

    State.prototype.actionsFor = function(character) {
      var _base;
      if (typeof (_base = this.actions)[character] === "function" ? _base[character](this.actions[character]) : void 0) {

      } else {
        return null;
      }
    };

    State.prototype.nextState = function() {
      return this.nextState;
    };

    return State;

  })();

  StateMachine = (function() {

    StateMachine.name = 'StateMachine';

    function StateMachine() {
      this.states = [];
      this.currentState = null;
    }

    StateMachine.prototype.addState = function(name, state) {
      return this.states[name] = state;
    };

    StateMachine.prototype.processState = function(character) {
      var actions;
      if (null === this.currentState) {
        throw new Error("Invalid state");
      } else {
        actions = this.currentState[character];
        this.currentState = this.currentState.nextState;
        return actions;
      }
    };

    return StateMachine;

  })();

  shiftTapeStep = function(xCoordFunc, stepNum, stepIndices) {
    var context, i, _i, _len;
    if (stepNum <= 100) {
      context = document.getElementById("paperTapeCanvas").getContext('2d');
      context.clearRect(0, 0, context.canvas.width, context.canvas.height);
      context.font = "bold 48px sans-serif";
      for (_i = 0, _len = stepIndices.length; _i < _len; _i++) {
        i = stepIndices[_i];
        context.beginPath();
        context.moveTo(xCoordFunc(i, stepNum), 0);
        context.lineTo(xCoordFunc(i, stepNum), 75);
        context.strokeStyle = "#999";
        context.closePath();
        context.stroke();
        context.fillText(symbols[i], i * 100 + 35 + stepNum, 50);
      }
      stepNum += 1;
      return setTimeout(function() {
        return shiftTapeStep(xCoordFunc, stepNum, stepIndices);
      }, 1);
    }
  };

  shiftTapeRight = function() {
    return shiftTapeStep(function(boxIndex, stepNum) {
      return boxIndex * 100 + stepNum;
    }, 0, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
  };

  shiftTapeLeft = function() {
    return shiftTapeStep(function(boxIndex, stepNum) {
      return boxIndex * 100 - stepNum;
    }, 0, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
  };

  init = function() {
    return $(function() {
      return $('#stateMachineDefinition').on('click', '.icon-plus-sign', function(eventObject) {
        var newRow;
        newRow = $('#stateRowTemplate').clone();
        $('#stateMachineDefinition').append(newRow);
        return $(eventObject.target).parent().empty();
      });
    });
  };

  $(document).ready(init);

}).call(this);
