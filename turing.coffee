
shiftTapeStep = (xCoordFunc, stepNum, stepIndices) ->
   if stepNum <= 100
      context = document.getElementById("paperTapeCanvas").getContext('2d')
      context.clearRect(0, 0, context.canvas.width, context.canvas.height)
   
      for i in stepIndices
         context.beginPath()
         context.moveTo(xCoordFunc(i, stepNum), 0)
         context.lineTo(xCoordFunc(i, stepNum), 75)
         context.strokeStyle = "#999"
         context.closePath()   
         context.stroke()
   
      stepNum += 1
      setTimeout(() ->
         shiftTapeStep(xCoordFunc, stepNum, stepIndices)
      , 1)
   
   
shiftTapeRight = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 + stepNum
   , 0, [0..7])
      

shiftTapeLeft = ->
   shiftTapeStep((boxIndex, stepNum) ->
      return boxIndex * 100 - stepNum
   , 0, [1..8])
      
init = ->
   shiftTapeLeft()


$(document).ready init

