
lastInstance = undefined
module.exports = ->

    lastInstance = local = 

        function1: ->

        function2: ->

        function3: ->

        function4: ->


    return api = 
        function1: local.function1
        function2: local.function2
        function3: local.function3
        function4: local.function4

module.exports._test = -> lastInstance
