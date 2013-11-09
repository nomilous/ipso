module.exports = class MyClass

    constructor: (@title) -> 

    thing: (arg) -> return 'Original Thing'

    callsNonExistantFunction: (arg) -> return @nonExistantFunction arg

