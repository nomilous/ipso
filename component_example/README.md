```
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


### injection example

```coffee

require('ipso').components (emitter) -> 

    #
    # components (and node_modules) are injected per the function argument names
    #

    e = new emitter
    e.on   'eventname', (payload) -> console.log received: payload
    e.emit 'eventname', 'DATA'

```

* There may be issues with component name collision
* Components with dots and dashes in their names cannot be injected this simply
* TODO: Solution is not yet clear

### **PENDING** - injection example using `component.inject.alias`

`component install nomilous/linux-if-stats`

When the `component.json` file contains the **custom** property

```json
{
    "inject": {
        "alias": "ifStats"
    },
}
```

Then the component becomes injectable by that name

```coffee

require('ipso').components (ifStats) -> 

    ifStats.start().then -> 

        console.log ifStats.current()

```
