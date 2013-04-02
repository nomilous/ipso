Validator = require '../validator'

class SpecRun extends Validator

    validate: -> 

        console.log 'VALIDATE'

    instance: -> 

        class: 'ipso:SpecRun'
        version: 0

    protocol: (When, Then) -> 


if typeof specRun == 'undefined'

    specRun = new SpecRun

module.exports = specRun
