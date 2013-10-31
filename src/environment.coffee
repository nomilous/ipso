{lstatSync, readFileSync} = require 'fs'
{EOL}  = require 'os'
colors = require 'colors'

module.exports.environment = (altEnv) -> 

    envFile = ".env.#{ altEnv || process.env.USER }"

    try stat = lstatSync envFile
    catch error
        if error.errno == 34 
            console.log 'ipso:', "warning: missing #{envFile}".yellow
            return 

    content = readFileSync envFile, 'utf8'
    for line in content.split EOL

        [m,key,value] = line.match /^(.*?)\=(.*)$/
        value = value.replace /^\'/, ''
        value = value.replace /\'$/, ''
        value = value.replace /\"$/, ''
        value = value.replace /^\"/, ''

        if key is 'NODE_ENV' and value is 'production'
            console.log 'ipso:', "warning: #{envFile} is PRODUCTION".yellow

        process.env[key] = value

    console.log 'ipso:', "loaded #{envFile}".green

