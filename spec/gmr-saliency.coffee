exec = require('child_process').exec
chai = require 'chai'
path = require 'path'
baseDir = path.resolve __dirname, '../'

describe 'Saliency', ->
  out = null

  @timeout 4000
  before (done) ->
    exec baseDir + '/bin/saliency ' + baseDir +  '/spec/fixtures/lenna.png', (err, stdout, stderr) ->
      if err
        done(err)
      else
        out = stdout
        done()

  it 'should output no error', ->
    chai.expect(out).to.be.equal ''