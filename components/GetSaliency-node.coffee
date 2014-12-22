noflo = require 'noflo'
temporary = require 'temporary'
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

  c.outPorts.add 'out',
    datatype: 'object'

  c.inPorts.add 'canvas', (event, payload) ->
    switch event
      when 'begingroup'
        c.outPorts.out.beginGroup payload
      when 'endgroup'
        c.outPorts.out.endGroup payload
      when 'data'
        compute payload, (out) ->
          c.outPorts.out.send out
      when 'disconnect'
        c.outPorts.out.disconnect()

  c