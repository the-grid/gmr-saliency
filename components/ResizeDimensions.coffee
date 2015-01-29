noflo = require 'noflo'

width = null
height = null

compute = (c) ->
  return unless width and height
  c.outPorts.width.send width/2
  c.outPorts.height.send height/2

exports.getComponent = ->
  c = new noflo.Component

  c.inPorts.add 'width', (event, payload) ->
    return unless event is 'data'
    width = payload
    compute(c)
  c.inPorts.add 'height', (event, payload) ->
    return unless event is 'data'
    height = payload
    compute(c)

  c.outPorts.add 'width'
  c.outPorts.add 'height'
  c