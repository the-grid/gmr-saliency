noflo = require 'noflo'
temporary = require 'temporary'
#Canvas = require('noflo-canvas').canvas
fs = require 'fs'
exec = require('child_process').exec

# @runtime noflo-nodejs
# @name GetSaliency

compute = (canvas, callback) ->
  # Get canvas
  ctx = canvas.getContext '2d'
  imageData = ctx.getImageData 0, 0, canvas.width, canvas.height
  data = imageData.data

  # Write on a temporary file
  tmpFile = new temporary.File
  out = fs.createWriteStream tmpFile.path
  stream = canvas.pngStream()
  stream.on 'data', (chunk) ->
    out.write(chunk)
  stream.on 'end', () ->
    try
      # Call saliency on the temporary file
      onEnd tmpFile.path, callback
    catch e
      tmpFile.unlink()

onEnd = (filePath, callback) ->
  saliencyBin = 'node_modules/.bin/saliency'

  exec saliencyBin + ' ' + filePath, (err, stdout, stderr) ->
    if err
      callback err
    else
      # Process the saliency output (parse and send)
      out = JSON.parse stdout
      callback out

exports.getComponent = ->
  c = new noflo.Component
  c.outPorts.add 'polygon'
  c.inPorts.add 'canvas', (event, payload) ->
    if event is 'begingroup'
      c.outPorts.polygon.beginGroup payload
    if event is 'endgroup'
      c.outPorts.polygon.endGroup payload
    return unless event is 'data'
    compute payload, (out) ->
      c.outPorts.polygon.send out

  c