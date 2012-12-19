machineTimer = null
shiftTimer = null
kThickLine = true

drawLine = (xCoord, drawThick) ->
   context = document.getElementById("paperTapeCanvas").getContext('2d')
   context.lineWidth = if drawThick then 5 else 1
   context.beginPath()
   context.moveTo(xCoord, 0)
   context.lineTo(xCoord, 50)
   context.closePath()
   context.stroke()

drawCurrentTapeSnapshot = () ->
   context = document.getElementById("paperTapeCanvas").getContext('2d')   
   for i in [0..8]
      drawLine(i * 100, !kThickLine)
      context.fillText(tape.characterAtIndex(i) , i * 100 + 35, 40);
   
   drawLine(400, kThickLine)
   drawLine(500, kThickLine)


shiftTapeStep = (xCoordFunc, inc, stepNum, stepIndices) ->
   context = document.getElementById("paperTapeCanvas").getContext('2d')

   if stepNum <= 100
      context.clearRect(0, 0, context.canvas.width, context.canvas.height)
      
      for i in stepIndices
         drawLine(xCoordFunc(i, stepNum), !kThickLine)
         charIndex = i - 1
         if inc
            charIndex = i + 1
         context.fillText(tape.characterAtIndex(charIndex), xCoordFunc(i, stepNum) + 35, 40);

   
      stepNum += 2
      shiftTimer = setTimeout(() ->
         shiftTapeStep(xCoordFunc, inc, stepNum, stepIndices)
      , 1)
   else
      # mark center square as current square being viewed
      drawLine(400, kThickLine)
      drawLine(500, kThickLine)

shiftHeadLeft = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 + stepNum
   , true, 0, [-1..8])
      

shiftHeadRight = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 - stepNum
   , false, 0, [0..9])


stateMachine = new Turing.StateMachine
tape = new Turing.Tape(4)

# The current operations being performed by the machine
currentOperations = []


nextOperation = () ->
   if 0 is currentOperations.length
      try
         currentOperations = stateMachine.processState(tape.currentCharacter())
      catch error
         alert(error)
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

   context = document.getElementById("paperTapeCanvas").getContext('2d')
   context.font = "bold 48px sans-serif";
   context.strokeStyle = "#000"

   drawCurrentTapeSnapshot()
   
   clearTable = ->
      clearInterval(machineTimer)
      clearInterval(shiftTimer)
      stateMachine.reset()
      tape.reset()
      context.clearRect(0, 0, context.canvas.width, context.canvas.height)
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
            try
               currentOperations = stateMachine.processState("")
               nextOperation()
            catch error
               alert(error)
      )
            
            
   $ ->
      $('#stateMachineTable').on('click', '.icon-plus-sign',
         (eventObject) -> 
            addRowToTable()
            $(eventObject.target).parent().empty())
            
   
   setPreconfiguredMachine = (machine) ->
      clearTable()
      $('#stateMachineTable').find('.icon-plus-sign').remove()
      numRows = machine.length
      numRow = 0
      for rowValues in machine
         newRow = addRowToTable()
         textFields = $(newRow).children('td').children('input')
         for i in [0...rowValues.length]
            textFields[i].value = rowValues[i]
            
         newRow.find('.icon-plus-sign').remove() if numRow < (numRows - 1)
         numRow += 1
         
       
            
   $ ->
      $('#alternating-machine').on('click',
         ->
            setPreconfiguredMachine(Turing.machines.alternatingOnesAndZeros)
      )

   $ ->
      $('#one-fourth-machine').on('click',
         ->
            setPreconfiguredMachine(Turing.machines.oneFourth)
      )
      
   $ ->
      $('#sequences-of-ones').on('click',
         ->
            setPreconfiguredMachine(Turing.machines.sequencesOfOnes)
      )
      
$(document).ready init


