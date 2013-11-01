
These examples outline some of the current functionalities of the ipso CLI. I have not mentioned the CLI on the main readme because it is not particularly intended for public consumption just yet. It's functionalities, interface and behaviour will change probably quite drastically as it grows into the tool i intend it to be. 

Start a [node-inspector](https://github.com/node-inspector/node-inspector) session.

```bash

$ ipso

ipso: expected directory: ./spec  # runs mocha coffee
ipso: expected directory: ./src   # compiles to lib (see ipso -h)
> 
> 
> moo
{ action: 'moo', args: [] }
> 
>

# 
# tab completion on commands and path
#

>
> node-inspect   [<web-port>, <debug-port>] <script>
> node-inspect 3001 7777 ex
> node-inspect 3001 7777 examples/ht
> node-inspect 3001 7777 examples/httpserver.js
> debugger listening on port 7777
> Server running at http://127.0.0.1:1337/
> Node Inspector v0.5.0
> info: socket.io started
> Visit http://127.0.0.1:3001/debug?port=7777 to start debugging.
>       -------------------------------------


```
