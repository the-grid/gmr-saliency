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
    out: ['width', 'height', 'factor']
    forwardGroups: true
  , (payload, groups, out, callback) ->
    width = payload.width
    height = payload.height
    max = Math.max width, height
    maxDimension = 256

    # Encoding: / factor. Decoding: * factor
    factor = max / maxDimension

    out.width.send payload.width / factor
    out.height.send payload.height / factor
    out.factor.send factor

  c