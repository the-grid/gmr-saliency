noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts.add 'width',
    datatype: 'object'
    required: true
    requiredForOutput: true

  c.inPorts.add 'height',
    datatype: 'object'
    required: true
    requiredForOutput: true

  c.outPorts.add 'width',
    datatype: 'object'
  c.outPorts.add 'height',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: ['width', 'height']
    out: ['width', 'height']
    forwardGroups: true
  , (payload, groups, out, callback) ->
    out.width.send payload.width / 2
    out.height.send payload.height / 2
  c