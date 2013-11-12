require 'colors'
{EOL} = require 'os'
{normalize, dirname, basename, relative} = require 'path'
{dirname, basename, relative, join} = require 'path'

module.exports.specLocation = specLocation = ->

    for line in (new Error).stack.split EOL

        baseName = undefined
        try [m, path, lineNrs] = line.match /.*\((.*?):(.*)/
        continue unless path?
        fileName = basename path
        try [m, baseName] = fileName.match /(.*)_spec.[coffee|js]/
        continue unless baseName
        specPath = relative process.cwd(), dirname path
        return {
            fileName: fileName
            baseName: baseName
            specPath: specPath
        }


module.exports.load = (templatePath) -> require templatePath

module.exports.save = (templateName, name, does) ->

    does.get query: tag: name, (err, entity) -> 

        if err?

            console.log 'ipso:', "could not save '#{name}' - #{err.message}"
            return

        #
        # load user template module from ~/.ipso/templates/templateName
        #

        try 

            templateModule = join process.env.HOME, '.ipso', 'templates', templateName
            loaded = module.exports.load templateModule

        catch error

            console.log error.message.red
            return



        renderedString = loaded.render 

            entity: entity






        # console.log 

        #     location: module.exports.specLocation()
        #     src: process.env.IPSO_SRC || 'src'
        #     entity: entity