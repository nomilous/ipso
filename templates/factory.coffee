###

Place into ~/.ipso/templates/factory.coffee to access as MissingModule.$save 'factory' 

###


module.exports.target = (pending, specLocation) ->

    #
    # opportunity to modify the render target
    # ---------------------------------------
    # 
    # * pending.path, pending.filename
    # 


module.exports.render = (entity) ->

    #
    # return a String to be writen to the target
    #

    body = """

    lastInstance = undefined
    module.exports = ->

        lastInstance = local = 

    """

    body += "\n        #{functionName}: ->\n"  for functionName of entity.functions
    body += "\n    return api ="
    body += "\n        #{functionName}: local.#{functionName}\n" for functionName of entity.functions
    body += """

    module.exports._test = -> lastInstance

    """

    return body
