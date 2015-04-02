exec = require('child_process').exec
chai = require 'chai'
path = require 'path'
baseDir = path.resolve __dirname, '../'

describe 'Saliency (C++)', ->
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

  it 'should extract a valid saliency profile', ->
    obj = JSON.parse out
    saliency = obj.saliency
    regions = saliency.regions

    chai.expect(regions[0].polygon).to.be.eql [[510,1],[456,59],[417,109],[396,111],[367,133],[352,138],[341,135],[331,125],[318,102],[294,75],[266,57],[231,45],[209,46],[196,52],[193,57],[217,65],[230,83],[226,103],[189,139],[189,165],[198,180],[197,191],[158,237],[135,244],[120,260],[108,261],[69,307],[63,324],[65,349],[60,358],[65,367],[66,466],[61,510],[172,510],[173,495],[183,483],[199,479],[215,484],[221,479],[224,468],[234,458],[242,428],[251,417],[302,414],[305,406],[317,397],[334,399],[351,415],[367,455],[380,410],[374,400],[375,358],[410,243],[447,158],[481,107],[484,82],[493,74],[510,72]]
    chai.expect(regions[0].center).to.be.eql [285, 255]
    chai.expect(Math.round(regions[0].radius)).to.be.equal 350
    chai.expect(regions[0].bounding_rect).to.be.eql [[60, 1], [511, 511]]