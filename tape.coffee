# Class to represent the paper tape to which
# the Turing machine writes

class Turing.Tape

   # initialPos should equal the mid-point of the tape in the UI
   constructor: (initialPos) ->
      @reset()
      @initialPos = initialPos
      
   reset: () ->
      @currentPos = @initialPos
      @printedCharacters = []
   
   # Perform the given operation on the tape
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
      if @printedCharacters[@currentPos - (@initialPos - index)]?
         return @printedCharacters[@currentPos - (@initialPos - index)]
      else
         return ""
