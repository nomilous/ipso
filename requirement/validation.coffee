Validation = require('nez').linked 'Validation'

Validation

    as:    'a validator'
    to:    'validate something'
    need:  'a way to receive the information necessary to validate'

    title: 'the prospect of confirmation', (spec) ->

        #
        # prospect |noun| ~ a potential fact
        # 

        spec.link 'spec/prospect'

