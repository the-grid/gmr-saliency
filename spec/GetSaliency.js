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
  var c, inImage, outPolygon;
  c = null;
  inImage = null;
  outPolygon = null;
  beforeEach(function() {
    c = GetSaliency.getComponent();
    inImage = noflo.internalSocket.createSocket();
    outPolygon = noflo.internalSocket.createSocket();
    c.inPorts.canvas.attach(inImage);
    return c.outPorts.polygon.attach(outPolygon);
  });
  describe('when instantiated', function() {
    it('should have one input port', function() {
      return chai.expect(c.inPorts.canvas).to.be.an('object');
    });
    return it('should have one output port', function() {
      return chai.expect(c.outPorts.polygon).to.be.an('object');
    });
  });
  return describe('with file system image', function() {
    return it('should extract a valid saliency profile', function(done) {
      var groups, id, inSrc;
      this.timeout(10000);
      id = null;
      groups = [];
      outPolygon.once('begingroup', function(group) {
        return groups.push(group);
      });
      outPolygon.once('data', function(res) {
        var saliency;
        chai.expect(res).to.be.an('object');
        saliency = res.saliency;
        chai.expect(saliency.polygon).to.be.eql([[510, 1], [494, 1], [494, 21], [456, 59], [418, 111], [396, 111], [374, 128], [333, 128], [318, 102], [294, 75], [256, 52], [231, 45], [209, 46], [196, 52], [193, 57], [217, 63], [221, 68], [221, 109], [189, 139], [191, 206], [180, 208], [178, 222], [167, 225], [161, 238], [131, 247], [130, 261], [108, 261], [108, 267], [92, 277], [92, 289], [79, 294], [79, 302], [69, 307], [63, 324], [60, 358], [65, 469], [61, 510], [173, 510], [174, 484], [215, 484], [221, 479], [221, 461], [233, 460], [241, 441], [243, 418], [252, 415], [302, 414], [304, 407], [344, 407], [360, 431], [367, 455], [370, 433], [377, 431], [380, 410], [375, 409], [375, 351], [381, 348], [419, 218], [451, 150], [481, 107], [481, 77], [484, 73], [510, 73]]);
        chai.expect(saliency.center).to.be.eql([285, 255]);
        chai.expect(Math.round(saliency.radius)).to.be.equal(350);
        chai.expect(saliency.bounding_rect).to.be.eql([[60, 1], [511, 511]]);
        return done();
      });
      inSrc = 'lenna.png';
      return id = testutils.getCanvasWithImageNoShift(inSrc, function(image) {
        inImage.beginGroup(id);
        inImage.send(image);
        return inImage.endGroup();
      });
    });
  });
});
