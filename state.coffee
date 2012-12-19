# A state is a dictionary that maps characters to
# the operations to perform when the character is 
# encountered and the state to transition to once 
# the operations are finished
class Turing.State
   @kOperationsKey = 'operations'
   @kNextStateKey = 'nextState'
   
   constructor: () ->
      @operations = {}
   
   getOperations: () ->
      return @operations
      
   addOperations: (character, operations, nextState) ->
      @operations[character] = {}
      @operations[character][State.kOperationsKey] = operations
      @operations[character][State.kNextStateKey] = nextState
   
   operationsFor: (character) ->
      return @getValueForCharacter(character, State.kOperationsKey)

   nextStateFor: (character) ->
      return @getValueForCharacter(character, State.kNextStateKey)
         
   getValueForCharacter: (character, keyValue) ->
      if @operations[character]?
         return @operations[character][keyValue]
      else if @operations['any']?
         return @operations['any'][keyValue]
      else
         throw new Error('Encountered invalid symbol.')
