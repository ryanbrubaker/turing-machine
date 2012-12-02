symbols = list = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i']


class State
   constructor: (@actions, @nextState) ->
   
   actionsFor: (character) ->
      if @actions[character]? @actions[character] else null
      
   nextState: ->
      return @nextState

class StateMachine
   constructor: () ->
      @states = []
      @currentState = null
      
   addState: (name, state) ->
      @states[name] = state
   
   ## Returns the actions for the current state based on the
   ## given character and moves to the next state. Assumes
   ## the controller updates the UI appropriately   
   processState: (character) ->
      if null is @currentState
         throw new Error("Invalid state")
      else
         actions = @currentState[character]
         @currentState = @currentState.nextState
         return actions
         
shiftTapeStep = (xCoordFunc, stepNum, stepIndices) ->
   if stepNum <= 100
      context = document.getElementById("paperTapeCanvas").getContext('2d')
      context.clearRect(0, 0, context.canvas.width, context.canvas.height)
      context.font = "bold 48px sans-serif";

      for i in stepIndices
         context.beginPath()
         context.moveTo(xCoordFunc(i, stepNum), 0)
         context.lineTo(xCoordFunc(i, stepNum), 75)
         context.strokeStyle = "#999"
         context.closePath()   
         context.stroke()
         context.fillText(symbols[i], i * 100 + 35 + stepNum, 50);

   
      stepNum += 1
      setTimeout(() ->
         shiftTapeStep(xCoordFunc, stepNum, stepIndices)
      , 1)
   
   
shiftTapeRight = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 + stepNum
   , 0, [0..8])
      

shiftTapeLeft = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 - stepNum
   , 0, [1..9])
      

init = ->
   #shiftTapeRight()
   
   $ ->
      $('#stateMachineDefinition').on('click', '.icon-plus-sign',
         (eventObject) -> 
            newRow = $('#stateRowTemplate').clone()
            $('#stateMachineDefinition').append(newRow)
            $(eventObject.target).parent().empty())
            

$(document).ready init

