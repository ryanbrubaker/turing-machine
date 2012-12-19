machineTimer = null
shiftTimer = null




class Tape
   constructor: () ->
      @reset()
   
   reset: () ->
      @currentPos = 4
      @printedCharacters = []
      
      
   doOperation: (operation) ->
      switch operation
         when "" then return
         when "E" then @printedCharacters[@currentPos] = ""
         when "L" 
            @currentPos -= 1
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


shiftTapeStep = (xCoordFunc, inc, stepNum, stepIndices) ->
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
         charIndex = i - 1
         if inc
            charIndex = i + 1
         context.fillText(tape.characterAtIndex(charIndex), xCoordFunc(i, stepNum) + 35, 40);

   
      stepNum += 1
      shiftTimer = setTimeout(() ->
         shiftTapeStep(xCoordFunc, inc, stepNum, stepIndices)
      , 1)
   else
      # mark center square as current square being viewed
      drawThickLine(400)
      drawThickLine(500)

shiftHeadLeft = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 + stepNum
   , true, 0, [0..8])
      

shiftHeadRight = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 - stepNum
   , false, 0, [1..9])


stateMachine = new Turing.StateMachine
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
         when "L" then shiftHeadLeft()   # we're actually shifting the head
         when "R" then shiftHeadRight()    # we're actually shifting the head
         else
            # Assuming we have a Px here since checks are done elsewhere
            drawCurrentTapeSnapshot()
            
   machineTimer = setTimeout(nextOperation, 500)
   

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
            for rowValues in Turing.machines.alternatingOnesAndZeros
               newRow = addRowToTable()
               textFields = $(newRow).children('td').children('input')
               for i in [0...rowValues.length]
                 textFields[i].value = rowValues[i]
      )

   $ ->
      $('#one-fourth-machine').on('click',
         ->
            clearTable()
            for rowValues in Turing.machines.oneFourth
               newRow = addRowToTable()
               textFields = $(newRow).children('td').children('input')
               for i in [0...rowValues.length]
                  textFields[i].value = rowValues[i]
      )
      
   $ ->
      $('#sequences-of-ones').on('click',
         ->
            clearTable()
            for rowValues in Turing.machines.sequencesOfOnes
               newRow = addRowToTable()
               textFields = $(newRow).children('td').children('input')
               for i in [0...rowValues.length]
                  textFields[i].value = rowValues[i]
      )
      
$(document).ready init


