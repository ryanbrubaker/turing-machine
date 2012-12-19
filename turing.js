// Generated by CoffeeScript 1.3.1
(function() {
  var StateMachine, Tape, currentOperations, drawCurrentTapeSnapshot, drawThickLine, init, machineTimer, nextOperation, shiftHeadLeft, shiftHeadRight, shiftTapeStep, shiftTimer, stateMachine, tape;

  machineTimer = null;

  shiftTimer = null;

  StateMachine = (function() {

    StateMachine.name = 'StateMachine';

    function StateMachine() {
      this.reset();
    }

    StateMachine.prototype.reset = function() {
      this.states = {};
      return this.currentState = null;
    };

    StateMachine.prototype.setup = function(states) {
      var character, currentStateName, i, initialStateName, newState, operations, state, stateName, _i, _j, _len, _ref, _ref1, _ref2;
      this.states = {};
      this.currentState = null;
      if (states.length === 0) {
        throw new Error("You must specify at least one state.");
      }
      initialStateName = null;
      currentStateName = null;
      for (_i = 0, _len = states.length; _i < _len; _i++) {
        state = states[_i];
        if (currentStateName === '' && state[0] === '') {
          throw new Error('State must have a name.');
        }
        if (state[1] === '') {
          throw new Error('State must specify a character.');
        }
        if (!this.validOperations(state[2])) {
          throw new Error('Allowed operations are "L", "R", "E", "P[x]"');
        }
        operations = [];
        if (state[2].length > 0) {
          operations = state[2].split(',');
        }
        for (i = _j = 0, _ref = operations.length; 0 <= _ref ? _j < _ref : _j > _ref; i = 0 <= _ref ? ++_j : --_j) {
          operations[i] = operations[i].trim();
        }
        if (state[0] === '') {
          this.states[currentStateName].addOperations(state[1], operations, state[3]);
        } else {
          currentStateName = state[0];
          if (!(initialStateName != null)) {
            initialStateName = currentStateName;
          }
          newState = new Turing.State;
          newState.addOperations(state[1], operations, state[3]);
          this.states[currentStateName] = newState;
        }
      }
      _ref1 = this.states;
      for (stateName in _ref1) {
        state = _ref1[stateName];
        _ref2 = state.getOperations();
        for (character in _ref2) {
          operations = _ref2[character];
          if (!this.states[operations[Turing.State.kNextStateKey]]) {
            throw new Error('Result state does not exist.');
          }
        }
      }
      return this.currentState = this.states[initialStateName];
    };

    StateMachine.prototype.validOperations = function(operationList) {
      var operation, operations, valid, _i, _len;
      valid = true;
      if ("" !== operationList) {
        operations = operationList.split(',');
        for (_i = 0, _len = operations.length; _i < _len; _i++) {
          operation = operations[_i];
          operation = operation.trim();
          valid = valid && ((operation === 'L' || operation === 'R' || operation === 'E') || (operation[0] === 'P' && operation.length === 2));
        }
      }
      return valid;
    };

    StateMachine.prototype.processState = function(character) {
      var operations;
      if (character === "") {
        character = 'none';
      }
      if (null === this.currentState) {
        throw new Error("Invalid state.");
      } else {
        operations = this.currentState.operationsFor(character).slice(0);
        this.currentState = this.states[this.currentState.nextStateFor(character)];
        return operations;
      }
    };

    return StateMachine;

  })();

  Tape = (function() {

    Tape.name = 'Tape';

    function Tape() {
      this.reset();
    }

    Tape.prototype.reset = function() {
      this.currentPos = 4;
      return this.printedCharacters = [];
    };

    Tape.prototype.doOperation = function(operation) {
      switch (operation) {
        case "":
          break;
        case "E":
          return this.printedCharacters[this.currentPos] = "";
        case "L":
          return this.currentPos -= 1;
        case "R":
          this.currentPos += 1;
          if (this.currentPos > this.printedCharacters.length) {
            return this.printedCharacters[this.currentPos] = "";
          }
          break;
        default:
          return this.printedCharacters[this.currentPos] = operation[1];
      }
    };

    Tape.prototype.currentCharacter = function() {
      return this.printedCharacters[this.currentPos] || '';
    };

    Tape.prototype.characterAtIndex = function(index) {
      if (this.printedCharacters[this.currentPos - (4 - index)] != null) {
        return this.printedCharacters[this.currentPos - (4 - index)];
      } else {
        return "";
      }
    };

    return Tape;

  })();

  drawThickLine = function(xCoord) {
    var context;
    context = document.getElementById("paperTapeCanvas").getContext('2d');
    context.lineWidth = 5;
    context.beginPath();
    context.moveTo(xCoord, 0);
    context.lineTo(xCoord, 50);
    context.closePath();
    return context.stroke();
  };

  drawCurrentTapeSnapshot = function() {
    var context, i, _i;
    context = document.getElementById("paperTapeCanvas").getContext('2d');
    context.lineWidth = 1;
    context.font = "bold 48px sans-serif";
    context.clearRect(0, 0, context.canvas.width, context.canvas.height);
    for (i = _i = 0; _i <= 8; i = ++_i) {
      context.beginPath;
      context.moveTo(i * 100, 0);
      context.lineTo(i * 100, 50);
      context.strokeStyle = "#000";
      context.closePath();
      context.stroke();
      context.fillText(tape.characterAtIndex(i), i * 100 + 35, 40);
    }
    drawThickLine(400);
    return drawThickLine(500);
  };

  shiftTapeStep = function(xCoordFunc, inc, stepNum, stepIndices) {
    var charIndex, context, i, _i, _len;
    context = document.getElementById("paperTapeCanvas").getContext('2d');
    context.lineWidth = 1;
    context.font = "bold 48px sans-serif";
    context.strokeStyle = "#000";
    if (stepNum <= 100) {
      context.clearRect(0, 0, context.canvas.width, context.canvas.height);
      for (_i = 0, _len = stepIndices.length; _i < _len; _i++) {
        i = stepIndices[_i];
        context.beginPath();
        context.moveTo(xCoordFunc(i, stepNum), 0);
        context.lineTo(xCoordFunc(i, stepNum), 50);
        context.closePath();
        context.stroke();
        charIndex = i - 1;
        if (inc) {
          charIndex = i + 1;
        }
        context.fillText(tape.characterAtIndex(charIndex), xCoordFunc(i, stepNum) + 35, 40);
      }
      stepNum += 1;
      return shiftTimer = setTimeout(function() {
        return shiftTapeStep(xCoordFunc, inc, stepNum, stepIndices);
      }, 1);
    } else {
      drawThickLine(400);
      return drawThickLine(500);
    }
  };

  shiftHeadLeft = function() {
    return shiftTapeStep(function(boxIndex, stepNum) {
      return boxIndex * 100 + stepNum;
    }, true, 0, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
  };

  shiftHeadRight = function() {
    return shiftTapeStep(function(boxIndex, stepNum) {
      return boxIndex * 100 - stepNum;
    }, false, 0, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
  };

  stateMachine = new StateMachine();

  currentOperations = [];

  tape = new Tape();

  nextOperation = function() {
    var operation;
    if (0 === currentOperations.length) {
      currentOperations = stateMachine.processState(tape.currentCharacter());
    } else {
      operation = currentOperations.shift();
      tape.doOperation(operation);
      switch (operation) {
        case "E":
          drawCurrentTapeSnapshot();
          break;
        case "L":
          shiftHeadLeft();
          break;
        case "R":
          shiftHeadRight();
          break;
        default:
          drawCurrentTapeSnapshot();
      }
    }
    return machineTimer = setTimeout(nextOperation, 500);
  };

  init = function() {
    var addRowToTable, clearTable;
    drawCurrentTapeSnapshot();
    clearTable = function() {
      var addRowCell, addedRows;
      clearInterval(machineTimer);
      clearInterval(shiftTimer);
      stateMachine.reset();
      tape.reset();
      drawCurrentTapeSnapshot();
      addedRows = $('.addedRow');
      if (addedRows.length > 0) {
        addedRows.remove();
        addRowCell = $(document.createElement('i'));
        addRowCell.addClass('icon-plus-sign');
        return $('#stateMachineTable th:first-child').html('<i class="icon-plus-sign"></i>');
      }
    };
    addRowToTable = function() {
      var newRow;
      newRow = $('#stateRowTemplate').clone();
      newRow.id = '';
      newRow.addClass('addedRow');
      $('#stateMachineTable').append(newRow);
      return newRow;
    };
    $(function() {
      return $('#clear-machine').on('click', clearTable);
    });
    $(function() {
      return $('#start-machine').on('click', function() {
        var i, row, stateRawData, stateRows, statesRawData, td, _i, _j, _len;
        try {
          stateRows = $('#stateMachineTable .addedRow');
          statesRawData = [];
          for (_i = 0, _len = stateRows.length; _i < _len; _i++) {
            row = stateRows[_i];
            stateRawData = [];
            for (i = _j = 1; _j <= 4; i = ++_j) {
              td = $(row).children()[i];
              stateRawData.push($(td).children()[0].value.trim());
            }
            statesRawData.push(stateRawData);
          }
          stateMachine.setup(statesRawData);
        } catch (error) {
          alert(error);
        }
        currentOperations = stateMachine.processState("");
        return nextOperation();
      });
    });
    $(function() {
      return $('#stateMachineTable').on('click', '.icon-plus-sign', function(eventObject) {
        addRowToTable();
        return $(eventObject.target).parent().empty();
      });
    });
    $(function() {
      return $('#alternating-machine').on('click', function() {
        var i, newRow, rowValues, textFields, _i, _len, _ref, _results;
        clearTable();
        _ref = Turing.machines.alternatingOnesAndZeros;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          rowValues = _ref[_i];
          newRow = addRowToTable();
          textFields = $(newRow).children('td').children('input');
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (i = _j = 0, _ref1 = rowValues.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
              _results1.push(textFields[i].value = rowValues[i]);
            }
            return _results1;
          })());
        }
        return _results;
      });
    });
    $(function() {
      return $('#one-fourth-machine').on('click', function() {
        var i, newRow, rowValues, textFields, _i, _len, _ref, _results;
        clearTable();
        _ref = Turing.machines.oneFourth;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          rowValues = _ref[_i];
          newRow = addRowToTable();
          textFields = $(newRow).children('td').children('input');
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (i = _j = 0, _ref1 = rowValues.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
              _results1.push(textFields[i].value = rowValues[i]);
            }
            return _results1;
          })());
        }
        return _results;
      });
    });
    return $(function() {
      return $('#sequences-of-ones').on('click', function() {
        var i, newRow, rowValues, textFields, _i, _len, _ref, _results;
        clearTable();
        _ref = Turing.machines.sequencesOfOnes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          rowValues = _ref[_i];
          newRow = addRowToTable();
          textFields = $(newRow).children('td').children('input');
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (i = _j = 0, _ref1 = rowValues.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
              _results1.push(textFields[i].value = rowValues[i]);
            }
            return _results1;
          })());
        }
        return _results;
      });
    });
  };

  $(document).ready(init);

}).call(this);
