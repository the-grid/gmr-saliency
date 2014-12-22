exec = require('child_process').exec
chai = require 'chai'
path = require 'path'
baseDir = path.resolve __dirname, '../'

describe 'GMR Saliency C++ exec', ->
  out = null

  @timeout 5000
  before (done) ->
    exec baseDir + '/build/Release/saliency ' + baseDir +  '/spec/fixtures/lenna.png', (err, stdout, stderr) ->
      if err
        done(err)
      else
        out = stdout
        done()

  it 'should output no error', ->
    chai.expect(out).to.be.an 'string'

  it 'should output a valid serialized object', ->
    obj = JSON.parse out
    chai.expect(obj).to.be.an 'object'

  it 'should extract a valid salient polygon', ->
    obj = JSON.parse out
    chai.expect(obj.salient_polygon).to.eql [[510, 1], [494, 1], [494, 21], [456, 59], [418, 111], [396, 111], [374, 128], [333, 128], [318, 102], [294, 75], [256, 52], [231, 45], [209, 46], [196, 52], [193, 57], [217, 63], [221, 68], [221, 109], [189, 139], [191, 206], [180, 208], [178, 222], [167, 225], [161, 238], [131, 247], [130, 261], [108, 261], [108, 267], [92, 277], [92, 289], [79, 294], [79, 302], [69, 307], [63, 324], [60, 358], [65, 469], [61, 510], [173, 510], [174, 484], [215, 484], [221, 479], [221, 461], [233, 460], [241, 441], [243, 418], [252, 415], [302, 414], [304, 407], [344, 407], [360, 431], [367, 455], [370, 433], [377, 431], [380, 410], [375, 409], [375, 351], [381, 348], [419, 218], [451, 150], [481, 107], [481, 77], [484, 73], [510,73]]