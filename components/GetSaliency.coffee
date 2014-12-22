noflo = require 'noflo'

# @runtime noflo-browser
# @name GetSaliency

# Stump component, does nothing on browser
exports.getComponent = ->
  c = new noflo.Component

  c.outPorts.add 'out',
    datatype: 'object'

  c.inPorts.add 'canvas', (event, payload) ->
    switch event
      when 'begingroup'
        c.outPorts.out.beginGroup payload
      when 'endgroup'
        c.outPorts.out.endGroup payload
      when 'data'
        c.outPorts.out.send
          saliency: null
      when 'disconnect'
        c.outPorts.out.disconnect()

  c