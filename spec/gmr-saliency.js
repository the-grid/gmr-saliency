var baseDir, chai, exec, path;

exec = require('child_process').exec;

chai = require('chai');

path = require('path');

baseDir = path.resolve(__dirname, '../');

describe('Saliency (C++)', function() {
  var out;
  out = null;
  this.timeout(5000);
  before(function(done) {
    return exec(baseDir + '/build/Release/saliency ' + baseDir + '/spec/fixtures/lenna.png', function(err, stdout, stderr) {
      if (err) {
        return done(err);
      } else {
        out = stdout;
        return done();
      }
    });
  });
  it('should output no error', function() {
    return chai.expect(out).to.be.an('string');
  });
  it('should output a valid serialized object', function() {
    var obj;
    obj = JSON.parse(out);
    return chai.expect(obj).to.be.an('object');
  });
  return it('should extract a valid saliency profile', function() {
    var bbox, bounding_rect, center, confidence, expected, obj, polygon, radius, regions, saliency;
    obj = JSON.parse(out);
    saliency = obj.saliency;
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
    return chai.expect(regions.length).to.be.gt(0);
  });
});
