var baseDir, chai, exec, path;

exec = require('child_process').exec;

chai = require('chai');

path = require('path');

baseDir = path.resolve(__dirname, '../');

describe('Saliency', function() {
  var out;
  out = null;
  this.timeout(4000);
  before(function(done) {
    return exec(baseDir + '/bin/saliency ' + baseDir + '/spec/fixtures/lenna.png', function(err, stdout, stderr) {
      if (err) {
        return done(err);
      } else {
        out = stdout;
        return done();
      }
    });
  });
  return it('should output no error', function() {
    return chai.expect(out).to.be.equal('');
  });
});
