noflo = require 'noflo'

# @runtime noflo-browser
# @name GetSaliency

# Stump component, does nothing on browser
exports.getComponent = ->
  c = new noflo.Component

  c.outPorts.add 'polygon',
    datatype: 'object'

  c.inPorts.add 'canvas', (event, payload) ->
    switch event
      when 'begingroup'
        c.outPorts.polygon.beginGroup payload
      when 'endgroup'
        c.outPorts.polygon.endGroup payload
      when 'data'
        c.outPorts.polygon.send
          saliency: null
      when 'disconnect'
        c.outPorts.polygon.disconnect()

  c