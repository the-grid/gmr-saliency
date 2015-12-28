noflo = require 'noflo'
temporary = require 'temporary'
fs = require 'fs'
path = require 'path'
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
      # Delay a bit to prevent premature end of stream
      setTimeout () ->
        onEnd tmpFile, callback
      , 100
    catch e
      callback e
      tmpFile.unlink()

onEnd = (tmpFile, callback) ->
  saliencyBin = path.join __dirname, '../build/Release/saliency'

  exec saliencyBin + ' ' + tmpFile.path, (err, stdout, stderr) ->
    tmpFile.unlink()
    if err
      callback err
      return
    else
      # Process the saliency output (parse and send)
      out = JSON.parse stdout
      callback null, out

exports.getComponent = ->
  c = new noflo.Component

  c.outPorts.add 'out',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  c.inPorts.add 'canvas',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'canvas'
    out: 'out'
    forwardGroups: true
    async: true
  , (payload, groups, out, callback) ->
    compute payload, (err, val) ->
      return callback err if err
      out.send val
      do callback
  c
