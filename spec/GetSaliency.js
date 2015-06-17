var GetSaliency, chai, noflo, testutils, validateWithThreshold;

noflo = require('noflo');

if (!noflo.isBrowser()) {
  if (!chai) {
    chai = require('chai');
  }
  GetSaliency = require('../components/GetSaliency-node.coffee');
  testutils = require('./testutils');
} else {
  GetSaliency = require('noflo-image/components/GetSaliency.js');
  testutils = require('noflo-image/spec/testutils.js');
}

validateWithThreshold = function(chai, calculated, expected, threshold) {
  var i, _i, _ref, _results;
  _results = [];
  for (i = _i = 0, _ref = calculated.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    chai.expect(calculated[i][0]).to.be.closeTo(expected[i][0], threshold);
    _results.push(chai.expect(calculated[i][1]).to.be.closeTo(expected[i][1], threshold));
  }
  return _results;
};

describe('GetSaliency component', function() {
  var c, inImage, out;
  c = null;
  inImage = null;
  out = null;
  before(function() {
    c = GetSaliency.getComponent();
    inImage = noflo.internalSocket.createSocket();
    out = noflo.internalSocket.createSocket();
    c.inPorts.canvas.attach(inImage);
    return c.outPorts.out.attach(out);
  });
  describe('when instantiated', function() {
    it('should have one input port', function() {
      return chai.expect(c.inPorts.canvas).to.be.an('object');
    });
    return it('should have one output port', function() {
      return chai.expect(c.outPorts.out).to.be.an('object');
    });
  });
  describe('with file system image', function() {
    var previous;
    previous = null;
    it('should extract a valid saliency profile', function(done) {
      var groups, id, inSrc;
      this.timeout(30000);
      id = 1;
      groups = [];
      out.once('begingroup', function(group) {
        return groups.push(group);
      });
      out.once('endgroup', function(group) {
        return groups.pop();
      });
      out.once('data', function(res) {
        var bbox, bounding_rect, center, confidence, expected, polygon, radius, regions, saliency;
        chai.expect(groups).to.eql([1]);
        chai.expect(res).to.be.an('object');
        saliency = res.saliency;
        previous = saliency;
        bounding_rect = saliency.bounding_rect, polygon = saliency.polygon, radius = saliency.radius, center = saliency.center, bbox = saliency.bbox, confidence = saliency.confidence, regions = saliency.regions;
        chai.expect(bounding_rect).to.exists;
        chai.expect(bounding_rect).to.be.an('array');
        chai.expect(polygon).to.exists;
        chai.expect(polygon).to.be.an('array');
        chai.expect(radius).to.exists;
        chai.expect(radius).to.be.a('number');
        chai.expect(center).to.exists;
        chai.expect(center).to.be.an('array');
        chai.expect(bbox).to.exists;
        chai.expect(bbox).to.be.an('object');
        chai.expect(confidence).to.exists;
        chai.expect(confidence).to.be.a('number');
        chai.expect(regions).to.exists;
        chai.expect(regions).to.be.an('array');
        chai.expect(regions[0]).to.exists;
        chai.expect(regions[0]).to.be.an('object');
        chai.expect(regions[0].bbox).to.exists;
        chai.expect(regions[0].bbox).to.be.an('object');
        chai.expect(regions[0].bbox.x).to.be.a('number');
        chai.expect(regions[0].bbox.y).to.be.a('number');
        chai.expect(regions[0].bbox.width).to.be.a('number');
        chai.expect(regions[0].bbox.height).to.be.a('number');
        chai.expect(regions[0].center).to.exists;
        chai.expect(regions[0].center).to.be.an('object');
        chai.expect(regions[0].center.x).to.be.a('number');
        chai.expect(regions[0].center.y).to.be.a('number');
        chai.expect(regions[0].radius).to.exists;
        chai.expect(regions[0].radius).to.be.a('number');
        chai.expect(regions[0].polygon).to.exists;
        chai.expect(regions[0].polygon).to.be.an('array');
        chai.expect(regions[0].polygon[0]).to.exists;
        chai.expect(regions[0].polygon[0]).to.be.an('object');
        chai.expect(regions[0].polygon[0].x).to.be.a('number');
        chai.expect(regions[0].polygon[0].y).to.be.a('number');
        expected = [[60, 1], [511, 511]];
        chai.expect(bounding_rect).to.be.deep.equal(expected);
        chai.expect(polygon).to.be.an('array');
        chai.expect(polygon.length).to.be.gt(0);
        chai.expect(radius).to.be.closeTo(350, 2);
        expected = [285, 255];
        chai.expect(center).to.be.deep.equal(expected);
        expected = {
          x: 60,
          y: 1,
          width: 451,
          height: 510
        };
        chai.expect(bbox).to.be.deep.equal(expected);
        chai.expect(confidence).to.be.lte(0.30);
        chai.expect(regions).to.be.an('array');
        chai.expect(regions.length).to.be.gt(0);
        return done();
      });
      inSrc = 'lenna.png';
      return testutils.getCanvasWithImageNoShift(inSrc, function(image) {
        inImage.beginGroup(id);
        inImage.send(image);
        return inImage.endGroup();
      });
    });
    return it('should extract a different saliency for a different image', function(done) {
      var groups, id, inSrc;
      this.timeout(30000);
      id = 2;
      groups = [];
      out.once('begingroup', function(group) {
        return groups.push(group);
      });
      out.once('endgroup', function(group) {
        return groups.pop();
      });
      out.once('data', function(res) {
        var saliency;
        chai.expect(groups).to.eql([2]);
        chai.expect(res).to.be.an('object');
        saliency = res.saliency;
        chai.expect(saliency).to.be.not.deep.equal(previous);
        return done();
      });
      inSrc = 'lenin.jpg';
      return testutils.getCanvasWithImageNoShift(inSrc, function(image) {
        inImage.beginGroup(id);
        inImage.send(image);
        return inImage.endGroup();
      });
    });
  });
  return describe('when passed a big image', function() {
    var input;
    input = 'alan-kay.png';
    return it('should extract the salient region in a reasonable time', function(done) {
      this.timeout(30000);
      if (console.timeEnd) {
        console.time('big image');
      }
      out.once("data", function(res) {
        if (console.timeEnd) {
          console.timeEnd('big image');
        }
        chai.expect(res).to.be.an('object');
        return done();
      });
      return testutils.getCanvasWithImageNoShift(input, function(canvas) {
        inImage.beginGroup(3);
        inImage.send(canvas);
        return inImage.endGroup();
      });
    });
  });
});
