{EOL} = require 'os'
{normalize, sep, dirname, basename, relative} = require 'path'
{dirname, basename, relative} = require 'path'

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

module.exports.save = (template, name, does) ->

    does.get query: tag: name, (err, entity) -> 

        console.log 

            location: specLocation()
            src: process.env.IPSO_SRC || 'src'
            entity: entity