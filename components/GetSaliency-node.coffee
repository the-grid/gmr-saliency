noflo = require 'noflo'
temporary = require 'temporary'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

# @runtime noflo-nodejs
# @name GetSaliency

writeCanvasTempFile = (canvas, callback) ->
  tmpFile = new temporary.File

  rs = canvas.pngStream()
  ws = fs.createWriteStream tmpFile.path

  rs.once 'error', (error) ->
    callback error
    tmpFile.unlink()
    return
  ws.once 'error', (error) ->
    callback error
    tmpFile.unlink()
    return
  ws.once 'open', (fd) ->
    if fd < 0
      callback new Error 'Bad file descriptor'
      tmpFile.unlink()
      return
    ws.once 'close', ->
      fs.fsync fd, ->
        try
          callback null, tmpFile
        catch error
          callback error
          tmpFile.unlink()
  rs.pipe ws

runSaliency = (tmpFile, callback) ->
  bin = path.join __dirname, '../build/Release/saliency'
  exec "#{bin} #{tmpFile.path}", (err, stdout, stderr) ->
    tmpFile.unlink()
    if err
      console.log 'GetSaliency ERROR:', err
      callback err
      return
    else
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
    out: [ 'out', 'error' ]
    forwardGroups: true
    async: true
  , (canvas, groups, out, callback) ->
    writeCanvasTempFile canvas, (err, tmpFile) ->
      if err
        if err.code is 'ENOMEM'
          console.log 'GetSaliency ERROR, sending empty saliency', err
          out.send
            saliency: null
          do callback
          return
        out.error.send err
        do callback
        return
      runSaliency tmpFile, (err, val) ->
        if err
          out.error.send err
          do callback
          return
        out.out.send val
        do callback
  c
