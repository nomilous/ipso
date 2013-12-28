**due homage:** [component](https://github.com/component/component)

```
# sudo npm install component -g
cd component_example
component install component/emitter
```

### basic example

```coffee

require('ipso').components()

#
# components then become requirable by name
#

Emitter = require 'emitter'
emitter = new Emitter

emitter.on   'eventname', (payload) -> console.log received: payload
emitter.emit 'eventname', 'DATA'

```

* TODO: What happens when a component has the same name as a native (or installed) node module.

