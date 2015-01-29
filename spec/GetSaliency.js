var GetSaliency, chai, noflo, testutils;

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
  return describe('with file system image', function() {
    it('should extract a valid saliency profile', function(done) {
      var groups, id, inSrc;
      this.timeout(10000);
      id = 1;
      groups = [];
      out.once('begingroup', function(group) {
        return groups.push(group);
      });
      out.once('endgroup', function(group) {
        return groups.pop();
      });
      out.once('data', function(res) {
        var saliency;
        chai.expect(groups).to.eql([1]);
        chai.expect(res).to.be.an('object');
        saliency = res.saliency;
        chai.expect(saliency.polygon).to.be.eql([[510, 1], [494, 1], [494, 21], [456, 59], [418, 111], [396, 111], [374, 128], [333, 128], [318, 102], [294, 75], [256, 52], [231, 45], [209, 46], [196, 52], [193, 57], [217, 63], [221, 68], [221, 109], [189, 139], [191, 206], [180, 208], [178, 222], [167, 225], [161, 238], [131, 247], [130, 261], [108, 261], [108, 267], [92, 277], [92, 289], [79, 294], [79, 302], [69, 307], [63, 324], [60, 358], [65, 469], [61, 510], [173, 510], [174, 484], [215, 484], [221, 479], [221, 461], [233, 460], [241, 441], [243, 418], [252, 415], [302, 414], [304, 407], [344, 407], [360, 431], [367, 455], [370, 433], [377, 431], [380, 410], [375, 409], [375, 351], [381, 348], [419, 218], [451, 150], [481, 107], [481, 77], [484, 73], [510, 73]]);
        chai.expect(saliency.center).to.be.eql([285, 255]);
        chai.expect(Math.round(saliency.radius)).to.be.equal(350);
        chai.expect(saliency.bounding_rect).to.be.eql([[60, 1], [511, 511]]);
        return done();
      });
      inSrc = 'lenna.png';
      return testutils.getCanvasWithImageNoShift(inSrc, function(image) {
        inImage.beginGroup(id);
        inImage.send(image);
        return inImage.endGroup();
      });
    });
    return it('should extract saliency with two images in a row', function(done) {
      var groups, id, inSrc;
      this.timeout(10000);
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
        chai.expect(saliency.polygon).to.be.eql([[77, 74], [93, 107], [93, 147], [84, 150], [77, 166], [84, 179], [84, 198], [116, 198], [116, 179], [124, 172], [124, 160], [116, 145], [108, 142], [108, 93], [112, 92], [102, 92]]);
        chai.expect(saliency.center).to.be.eql([96, 136]);
        chai.expect(Math.round(saliency.radius)).to.be.equal(67);
        chai.expect(saliency.bounding_rect).to.be.eql([[77, 74], [125, 199]]);
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
});
