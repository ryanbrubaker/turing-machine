symbols = list = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i']

class State
   constructor: (nextState) ->
      @operations = {}
      @nextState = nextState
   
   addOperation: (character, operations) ->
      @operations[character] = operations
   
   operationsFor: (character) ->
      if @operations[character]? 
         return @operations[character] 
      else 
         throw new Error('Encountered invalid symbol.')
      
   nextState: ->
      return @nextState

class StateMachine
   constructor: () ->
      @states = {}
      @currentState = null
      
   setup: (states) ->
      @states = {}
      @currentState = null
      throw new Error("You must specify at least one state.") if states.length is 0
      initialStateName = ''
      currentStateName = ''
      
      for state in states
         throw new Error('State must have a name.') if currentStateName is '' and state[0] is '' 
         throw new Error('State must specify a character.') if state[1] is ''
         throw new Error('Allowed operations are "L", "R", "E", "P[x]"') if not @validOperations(state[2])
         
         if state[0] is ''
            @states[currentStateName].addOperation(state[1], state[2])
         else
            currentStateName = state[0]
            newState = new State(state[3])
            newState.addOperation(state[1], state[2])
            @states[currentStateName] = newState
      
      for stateName, state of @states
         if not(@states[state.nextState]?)
            throw new Error('Result state does not exist.')
      
      currentState = @states[initialStateName]
   
   goNextState: ->
      @currentState = @currentState.nextState
      
   validOperations: (operationList) ->
      valid = true
      operations = operationList.split(',')
      for operation in operations
         operation = operation.trim()
         valid = valid and
                  ((operation is 'L' or operation is 'R' or operation is 'E') or
                   (operation[0] is 'P' and operation.length is 2))
      return valid
   
   ## Returns the operations for the current state based on the
   ## given character and moves to the next state. Assumes
   ## the controller updates the UI appropriately   
   processState: (character) ->
      if null is @currentState
         throw new Error("Invalid state.")
      else
         operations = @currentState[character]
         @currentState = @currentState.nextState
         return operations
         
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
   
   stateMachine = new StateMachine()
   
   $ ->
      $('#start-machine').on('click', 
         ->
            try
               stateRows = $('#stateMachineTable .addedRow')
               statesRawData = []
               for row in stateRows
                  stateRawData = []
                  for i in [1..4]
                     td = $(row).children()[i]
                     stateRawData.push($(td).children()[0].value.trim())
                  statesRawData.push(stateRawData)
               stateMachine.setup(statesRawData)
            catch error
               alert(error)
            )
            
   $ ->
      $('#stateMachineTable').on('click', '.icon-plus-sign',
         (eventObject) -> 
            newRow = $('#stateRowTemplate').clone()
            newRow.id = ''
            $('#stateMachineTable').append(newRow)
            $(eventObject.target).parent().empty())
            

$(document).ready init

