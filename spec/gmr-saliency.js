var baseDir, chai, exec, path;

exec = require('child_process').exec;

chai = require('chai');

path = require('path');

baseDir = path.resolve(__dirname, '../');

describe('Saliency', function() {
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
  return it('should extract a valid salient polygon', function() {
    var obj;
    obj = JSON.parse(out);
    return chai.expect(obj.salient_polygon).to.eql([[510, 1], [494, 1], [494, 21], [456, 59], [418, 111], [396, 111], [374, 128], [333, 128], [318, 102], [294, 75], [256, 52], [231, 45], [209, 46], [196, 52], [193, 57], [217, 63], [221, 68], [221, 109], [189, 139], [191, 206], [180, 208], [178, 222], [167, 225], [161, 238], [131, 247], [130, 261], [108, 261], [108, 267], [92, 277], [92, 289], [79, 294], [79, 302], [69, 307], [63, 324], [60, 358], [65, 469], [61, 510], [173, 510], [174, 484], [215, 484], [221, 479], [221, 461], [233, 460], [241, 441], [243, 418], [252, 415], [302, 414], [304, 407], [344, 407], [360, 431], [367, 455], [370, 433], [377, 431], [380, 410], [375, 409], [375, 351], [381, 348], [419, 218], [451, 150], [481, 107], [481, 77], [484, 73], [510, 73]]);
  });
});
