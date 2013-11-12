require 'colors'
{EOL} = require 'os'
{normalize, dirname, basename, relative, join, sep} = require 'path'
mkdirp = require 'mkdirp'
{writeFileSync} = require 'fs'

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

            templateModulePath = join process.env.HOME, '.ipso', 'templates', templateName
            templateModule = module.exports.load templateModulePath

        catch error
            console.log error.message.red
            return


        specLocation = module.exports.specLocation()
        pathParts    = specLocation.specPath.split sep
        pathParts.shift()
        pathParts.unshift process.env.IPSO_SRC || 'src'


        sourceFile = 
            path: process.cwd() + sep + pathParts.join sep
            filename: specLocation.baseName + '.coffee'


        if typeof templateModule.target is 'function' 

            templateModule.target sourceFile, specLocation


        if typeof templateModule.render is 'function' 

            moduleBody = templateModule.render entity

        if typeof moduleBody is 'string' 

            mkdirp.sync sourceFile.path
            fileName =  join sourceFile.path, sourceFile.filename
            writeFileSync fileName, moduleBody
            console.log 'ipso:', "Created #{fileName}".green
            console.log moduleBody



        # console.log 

        #     location: module.exports.specLocation()
        #     src: process.env.IPSO_SRC || 'src'
        #     entity: entity

