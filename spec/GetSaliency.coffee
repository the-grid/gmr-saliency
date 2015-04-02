noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  GetSaliency = require '../components/GetSaliency-node.coffee'
  testutils = require './testutils'
else
  GetSaliency = require 'noflo-image/components/GetSaliency.js'
  testutils = require 'noflo-image/spec/testutils.js'

validateWithThreshold = (chai, calculated, expected, threshold) ->
  for i in [0...calculated.length]
    diffX = Math.abs(calculated[i][0] - expected[i][0])
    diffY = Math.abs(calculated[i][1] - expected[i][1])
    chai.expect(diffX).to.be.at.most threshold
    chai.expect(diffY).to.be.at.most threshold
 
describe 'GetSaliency component', ->
 
  c = null
  inImage = null
  out = null

  before ->
    c = GetSaliency.getComponent()
    inImage = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.canvas.attach inImage
    c.outPorts.out.attach out
 
  describe 'when instantiated', ->
    it 'should have one input port', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
 
  describe 'with file system image', ->
    it 'should extract a valid saliency profile', (done) ->
      @timeout 10000
      id = 1
      groups = []
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.eql [1]
        chai.expect(res).to.be.an 'object'
        saliency = res.saliency
        outmost_rect = saliency.outmost_rect
        regions = saliency.regions

        expected = [[510,1],[456,59],[417,109],[396,111],[367,133],[352,138],[341,135],[331,125],[318,102],[294,75],[266,57],[231,45],[209,46],[196,52],[193,57],[217,65],[230,83],[226,103],[189,139],[189,165],[198,180],[197,191],[158,237],[135,244],[120,260],[108,261],[69,307],[63,324],[65,349],[60,358],[65,367],[66,466],[61,510],[172,510],[173,495],[183,483],[199,479],[215,484],[221,479],[224,468],[234,458],[242,428],[251,417],[302,414],[305,406],[317,397],[334,399],[351,415],[367,455],[380,410],[374,400],[375,358],[410,243],[447,158],[481,107],[484,82],[493,74],[510,72]]
        validateWithThreshold chai, regions[0].polygon, expected, 15
        # chai.expect(saliency.center).to.be.eql [285, 255]
        # chai.expect(Math.round(saliency.radius)).to.be.equal 350
        # chai.expect(saliency.bounding_rect).to.be.eql [[60, 1], [511, 511]]
        done()

      inSrc = 'lenna.png'
      testutils.getCanvasWithImageNoShift inSrc, (image) ->
        inImage.beginGroup id
        inImage.send image
        inImage.endGroup()

    it 'should extract saliency with two images in a row', (done) ->
      @timeout 10000
      id = 2
      groups = []
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.eql [2]
        chai.expect(res).to.be.an 'object'
        saliency = res.saliency
        outmost_rect = saliency.outmost_rect
        regions = saliency.regions
        expected = [[77,74],[83,92],[103,123],[100,139],[84,150],[77,166],[95,198],[103,198],[106,188],[124,172],[124,160],[107,132],[107,101],[112,92],[98,89]]
        validateWithThreshold chai, regions[0].polygon, expected, 15
        # chai.expect(saliency.center).to.be.eql [96, 136]
        # chai.expect(Math.round(saliency.radius)).to.be.equal 67
        # chai.expect(saliency.bounding_rect).to.be.eql [[77, 74], [125, 199]]
        done()

      inSrc = 'lenin.jpg'
      testutils.getCanvasWithImageNoShift inSrc, (image) ->
        inImage.beginGroup id
        inImage.send image
        inImage.endGroup()

  describe 'when passed a big image', ->
    input = 'alan-kay.png'

    it 'should extract the salient region in a reasonable time', (done) ->
      @timeout 10000
      if console.timeEnd
        console.time 'big image'
      out.once "data", (res) ->
        if console.timeEnd
          console.timeEnd 'big image'
        chai.expect(res).to.be.an 'object'
        done()
      testutils.getCanvasWithImageNoShift input, (canvas) ->
        inImage.beginGroup 3
        inImage.send canvas
        inImage.endGroup()
