# Class to represent the set of states for
# a Turing machine

class Turing.StateMachine

   constructor: () ->
      @reset()
      
   reset: () ->
      @states = {}
      @currentState = null
   
   # states param is an n x 4 array
   #  n[0] = a state name or blank if it is a continuation of the current state
   #  n[1] = a character that can be processed by this state
   #  n[2] = the operations to perform when the character is encountered in this state
   #  n[3] = the state to transition to after performing all operations
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
         
         operations = []
         if (state[2].length > 0)
            operations = state[2].split(',')
            
         for i in [0...operations.length]
            operations[i] = operations[i].trim()
         
         # A continuation of the current state
         if state[0] is ''
            @states[currentStateName].addOperations(state[1], operations, state[3])
         else
            # a new state
            currentStateName = state[0]
            newState = new Turing.State
            newState.addOperations(state[1], operations, state[3])
            @states[currentStateName] = newState
            
            # First state specified is considered initial state
            initialStateName = currentStateName if not initialStateName?
      
      for stateName, state of @states
         # Check to make sure end state actually exists
         for character, operations of state.getOperations()
            if not(@states[operations[Turing.State.kNextStateKey]])
               throw new Error('Result state does not exist.')
      
      @currentState = @states[initialStateName]
      
   
   # Check to make sure the operations specified are valid
   validOperations: (operationList) ->
      valid = true
      if "" != operationList
         operations = operationList.split(',')
         for operation in operations
            operation = operation.trim()
            valid = valid and
                     ((operation is 'L' or operation is 'R' or operation is 'E') or
                     (operation[0] is 'P' and operation.length is 2))
      return valid
   
   # Returns the operations for the current state based on the
   # given character and moves to the next state. Assumes
   # the controller updates the UI appropriately and will then
   # be ready for the new state    
   processState: (character) ->
      character = 'none' if character is ""
      if null is @currentState
         throw new Error("Invalid state.")
      else
         # return a copy of the array
         operations = @currentState.operationsFor(character).slice(0)
         @currentState = @states[@currentState.nextStateFor(character)]
         return operations