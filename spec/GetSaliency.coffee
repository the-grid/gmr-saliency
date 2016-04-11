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
    chai.expect(calculated[i][0]).to.be.closeTo expected[i][0], threshold
    chai.expect(calculated[i][1]).to.be.closeTo expected[i][1], threshold

describe 'GetSaliency component', ->

  c = null
  inImage = null
  out = null
  error = null

  before ->
    c = GetSaliency.getComponent()
    inImage = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.canvas.attach inImage
    c.outPorts.out.attach out
    c.outPorts.error.attach error

  describe 'when instantiated', ->
    it 'should have one input port', ->
      chai.expect(c.inPorts.canvas).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
    it 'should have one error port', ->
      chai.expect(c.outPorts.error).to.be.an 'object'

  describe 'with file system image', ->
    previous = null
    it 'should extract a valid saliency profile', (done) ->
      @timeout 30000
      id = 1
      groups = []
      error.once 'data', (err) ->
        console.log 'err', err
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.eql [1]
        chai.expect(res).to.be.an 'object'
        {saliency} = res
        previous = saliency
        {bounding_rect, polygon, radius, center, bbox, confidence, regions} = saliency

        # Check if every field exists and have the right types
        chai.expect(bounding_rect).to.exists
        chai.expect(bounding_rect).to.be.an 'array'
        chai.expect(polygon).to.exists
        chai.expect(polygon).to.be.an 'array'
        chai.expect(radius).to.exists
        chai.expect(radius).to.be.a 'number'
        chai.expect(center).to.exists
        chai.expect(center).to.be.an 'array'
        chai.expect(bbox).to.exists
        chai.expect(bbox).to.be.an 'object'
        chai.expect(confidence).to.exists
        chai.expect(confidence).to.be.a 'number'
        chai.expect(regions).to.exists
        chai.expect(regions).to.be.an 'array'
        chai.expect(regions[0]).to.exists
        chai.expect(regions[0]).to.be.an 'object'
        chai.expect(regions[0].bbox).to.exists
        chai.expect(regions[0].bbox).to.be.an 'object'
        chai.expect(regions[0].bbox.x).to.be.a 'number'
        chai.expect(regions[0].bbox.y).to.be.a 'number'
        chai.expect(regions[0].bbox.width).to.be.a 'number'
        chai.expect(regions[0].bbox.height).to.be.a 'number'
        chai.expect(regions[0].center).to.exists
        chai.expect(regions[0].center).to.be.an 'object'
        chai.expect(regions[0].center.x).to.be.a 'number'
        chai.expect(regions[0].center.y).to.be.a 'number'
        chai.expect(regions[0].radius).to.exists
        chai.expect(regions[0].radius).to.be.a 'number'
        chai.expect(regions[0].polygon).to.exists
        chai.expect(regions[0].polygon).to.be.an 'array'
        chai.expect(regions[0].polygon[0]).to.exists
        chai.expect(regions[0].polygon[0]).to.be.an 'object'
        chai.expect(regions[0].polygon[0].x).to.be.a 'number'
        chai.expect(regions[0].polygon[0].y).to.be.a 'number'

        expected = [[60, 1], [511, 511]]
        chai.expect(bounding_rect).to.be.deep.equal expected
        chai.expect(polygon).to.be.an 'array'
        chai.expect(polygon.length).to.be.gt 0
        chai.expect(radius).to.be.closeTo 350, 2
        expected = [285, 255]
        chai.expect(center).to.be.deep.equal expected
        expected =
          x: 60
          y: 1
          width: 451
          height: 510
        chai.expect(bbox).to.be.deep.equal expected
        chai.expect(confidence).to.be.lte 0.30
        chai.expect(regions).to.be.an 'array'
        chai.expect(regions.length).to.be.gt 0
        done()

      inSrc = 'lenna.png'
      testutils.getCanvasWithImageNoShift inSrc, (image) ->
        inImage.beginGroup id
        inImage.send image
        inImage.endGroup()

    it 'should extract a different saliency for a different image', (done) ->
      @timeout 30000
      id = 2
      groups = []
      error.once 'data', (err) ->
        console.log 'err', err
      out.once 'begingroup', (group) ->
        groups.push group
      out.once 'endgroup', (group) ->
        groups.pop()
      out.once 'data', (res) ->
        chai.expect(groups).to.eql [2]
        chai.expect(res).to.be.an 'object'
        {saliency} = res
        chai.expect(saliency).to.be.not.deep.equal previous
        done()

      inSrc = 'lenin.jpg'
      testutils.getCanvasWithImageNoShift inSrc, (image) ->
        inImage.beginGroup id
        inImage.send image
        inImage.endGroup()

  describe 'when passed a big image', ->
    input = 'alan-kay.png'

    it 'should extract the salient region in a reasonable time', (done) ->
      @timeout 30000
      if console.timeEnd
        console.time 'big image'
      error.once 'data', (err) ->
        console.log 'err', err
      out.once 'data', (res) ->
        if console.timeEnd
          console.timeEnd 'big image'
        chai.expect(res).to.be.an 'object'
        done()
      testutils.getCanvasWithImageNoShift input, (canvas) ->
        inImage.beginGroup 3
        inImage.send canvas
        inImage.endGroup()

  describe 'when passed an image with small width', ->
    input = 'small_width.jpg'

    it 'should extract the salient region in a reasonable time', (done) ->
      @timeout 30000
      error.once 'data', (err) ->
        console.log 'err', err
      out.once 'data', (res) ->
        chai.expect(res).to.be.an 'object'
        done()
      testutils.getCanvasWithImageNoShift input, (canvas) ->
        inImage.beginGroup 3
        inImage.send canvas
        inImage.endGroup()

  describe 'when passed an image with small height', ->
    input = 'small_height.jpg'

    it 'should extract the salient region in a reasonable time', (done) ->
      @timeout 30000
      error.once 'data', (err) ->
        console.log 'err', err
      out.once 'data', (res) ->
        chai.expect(res).to.be.an 'object'
        done()
      testutils.getCanvasWithImageNoShift input, (canvas) ->
        inImage.beginGroup 3
        inImage.send canvas
        inImage.endGroup()
  describe 'when passed a small gif', ->
    input = 'small.gif'

    it 'should extract the salient region in a reasonable time', (done) ->
      @timeout 30000
      error.once 'data', (err) ->
        console.log 'err', err
      out.once 'data', (res) ->
        chai.expect(res).to.be.an 'object'
        done()
      testutils.getCanvasWithImageNoShift input, (canvas) ->
        inImage.beginGroup 4
        inImage.send canvas
        inImage.endGroup()
