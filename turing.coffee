alternatingOnesAndZeros = [
   ['a', 'none',        'P0', 'a'],
   [ '',    '0',  'R, R, P1', 'a'],
   [ '',    '1',  'R, R, P0', 'a']
]

machineTimer = null
shiftTimer = null

class State
   constructor: (nextState) ->
      @operations = {}
      @nextState = nextState
   
   addOperations: (character, operations) ->
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
      @reset()
      
   reset: () ->
      @states = {}
      @currentState = null
      
   setup: (states) ->
      @states = {}
      @currentState = null
      throw new Error("You must specify at least one state.") if states.length is 0
      initialStateName = null
      currentStateName = null
      
      for state in states
         throw new Error('State must have a name.') if currentStateName is '' and state[0] is '' 
         throw new Error('State must specify a character.') if state[1] is ''
         throw new Error('Allowed operations are "L", "R", "E", "P[x]"') if not @validOperations(state[2])
         
         operations = state[2].split(',')
         for i in [0...operations.length]
            operations[i] = operations[i].trim()
         
         if state[0] is ''
            @states[currentStateName].addOperations(state[1], operations)
         else
            currentStateName = state[0]
            initialStateName = currentStateName if not initialStateName?
            newState = new State(state[3])
            newState.addOperations(state[1], operations)
            @states[currentStateName] = newState
      
      for stateName, state of @states
         if not(@states[state.nextState]?)
            throw new Error('Result state does not exist.')
      
      @currentState = @states[initialStateName]
   
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
      character = 'none' if character is ""
      if null is @currentState
         throw new Error("Invalid state.")
      else
         operations = @currentState.operationsFor(character).slice(0)
         @currentState = @states[@currentState.nextState]
         return operations

class Tape
   constructor: () ->
      @reset()
   
   reset: () ->
      @currentPos = 4
      @printedCharacters = []
      
      
   doOperation: (operation) ->
      switch operation
         when "E" then @printedCharacters[@currentPos] = ""
         when "L" then @currentPos -= 1
         when "R" 
            @currentPos += 1
            @printedCharacters[@currentPos] = "" if @currentPos > @printedCharacters.length
         else
            # Assuming we have a Px here since checks are done elsewhere
            @printedCharacters[@currentPos] = operation[1]
   
   currentCharacter: () ->
      return @printedCharacters[@currentPos] || ''
      
   characterAtIndex: (index) ->
      if @printedCharacters[@currentPos - (4 - index)]?
         return @printedCharacters[@currentPos - (4 - index)]
      else
         return ""

drawThickLine = (xCoord) ->
   context = document.getElementById("paperTapeCanvas").getContext('2d')
   context.lineWidth = 5;
   context.beginPath()
   context.moveTo(xCoord, 0)
   context.lineTo(xCoord, 50)
   context.closePath()
   context.stroke()


drawCurrentTapeSnapshot = () ->
   context = document.getElementById("paperTapeCanvas").getContext('2d')
   context.lineWidth = 1;
   context.font = "bold 48px sans-serif";
   context.clearRect(0, 0, context.canvas.width, context.canvas.height)
   
   for i in [0..8]
      context.beginPath
      context.moveTo(i * 100, 0)
      context.lineTo(i * 100, 50)
      context.strokeStyle = "#000"
      context.closePath()   
      context.stroke()
      context.fillText(tape.characterAtIndex(i) , i * 100 + 35, 40);
   
   drawThickLine(400)
   drawThickLine(500)


shiftTapeStep = (xCoordFunc, stepNum, stepIndices) ->
   context = document.getElementById("paperTapeCanvas").getContext('2d')
   context.lineWidth = 1;
   context.font = "bold 48px sans-serif";
   context.strokeStyle = "#000"

   if stepNum <= 100
      context.clearRect(0, 0, context.canvas.width, context.canvas.height)
      
      for i in stepIndices
         context.beginPath()
         context.moveTo(xCoordFunc(i, stepNum), 0)
         context.lineTo(xCoordFunc(i, stepNum), 50)
         context.closePath()   
         context.stroke()
         context.fillText(tape.characterAtIndex(i) , i * 100 + 35 - stepNum, 40);

   
      stepNum += 1
      shiftTimer = setTimeout(() ->
         shiftTapeStep(xCoordFunc, stepNum, stepIndices)
      , 1)
   else
      # mark center square as current square being viewed
      drawThickLine(400)
      drawThickLine(500)

shiftTapeRight = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 + stepNum
   , 0, [0..8])
      

shiftTapeLeft = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 - stepNum
   , 0, [1..9])


stateMachine = new StateMachine()
currentOperations = []
tape = new Tape()

nextOperation = () ->
   if 0 is currentOperations.length
      currentOperations = stateMachine.processState(tape.currentCharacter())
   else
      operation = currentOperations.shift()
      tape.doOperation(operation)
      switch operation
         when "E" then drawCurrentTapeSnapshot()
         when "L" then shiftTapeRight()   # we're actually shifting the head
         when "R" then shiftTapeLeft()    # we're actually shifting the head
         else
            # Assuming we have a Px here since checks are done elsewhere
            drawCurrentTapeSnapshot()
            
   machineTimer = setTimeout(nextOperation, 1000)
   

init = ->

   drawCurrentTapeSnapshot()
   
   clearTable = ->
      clearInterval(machineTimer)
      clearInterval(shiftTimer)
      stateMachine.reset()
      tape.reset()
      drawCurrentTapeSnapshot()
      addedRows = $('.addedRow')
      if addedRows.length > 0
         addedRows.remove()
         addRowCell = $(document.createElement('i'))
         addRowCell.addClass('icon-plus-sign')
         $('#stateMachineTable th:first-child').html('<i class="icon-plus-sign"></i>')

   addRowToTable = ->
      newRow = $('#stateRowTemplate').clone()
      newRow.id = ''
      newRow.addClass('addedRow')
      $('#stateMachineTable').append(newRow)
      return newRow
      
   $ ->
      $('#clear-machine').on('click', clearTable)
   
   $ ->
      $('#start-machine').on('click', 
         ->
            # read in the state machine defined by the user
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
            
            # now run it
            currentOperations = stateMachine.processState("")
            nextOperation()
      )
            
            
   $ ->
      $('#stateMachineTable').on('click', '.icon-plus-sign',
         (eventObject) -> 
            addRowToTable()
            $(eventObject.target).parent().empty())
            
   $ ->
      $('#alternating-machine').on('click',
         ->
            clearTable()
            for rowValues in alternatingOnesAndZeros
               newRow = addRowToTable()
               textFields = $(newRow).children('td').children('input')
               for i in [0...rowValues.length]
                 textFields[i].value = rowValues[i]
      )

$(document).ready init


