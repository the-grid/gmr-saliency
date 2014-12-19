var Canvas, createCanvas, fs, getCanvasWithImage, getCanvasWithImageNoShift, getData, getImageData, noflo, writeOut, writePNG;

noflo = require('noflo');

if (!noflo.isBrowser()) {
  fs = require('fs');
  Canvas = require('noflo-canvas').canvas;
}

createCanvas = function(width, height) {
  var canvas;
  if (noflo.isBrowser()) {
    canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
  } else {
    Canvas = require('noflo-canvas').canvas;
    canvas = new Canvas(width, height);
  }
  return canvas;
};

getImageData = function(name, callback) {
  var id, image;
  if (noflo.isBrowser()) {
    id = 'http://localhost:8000/spec/fixtures/' + name;
    image = new Image();
    image.onload = function() {
      return callback(image);
    };
    image.src = id;
  } else {
    id = 'spec/fixtures/' + name;
    fs.readFile(id, function(err, data) {
      image = new Canvas.Image;
      image.src = data;
      return callback(image);
    });
  }
  return id;
};

getCanvasWithImage = function(name, callback) {
  var id;
  id = getImageData(name, function(img) {
    var canvas;
    canvas = createCanvas(img.width, img.height);
    canvas.getContext('2d').drawImage(img, img.width * 0.25, img.height * 0.25);
    return callback(canvas);
  });
  return id;
};

getCanvasWithImageNoShift = function(name, callback) {
  var id;
  id = getImageData(name, function(img) {
    var canvas;
    canvas = createCanvas(img.width, img.height);
    canvas.getContext('2d').drawImage(img, 0, 0);
    return callback(canvas);
  });
  return id;
};

getData = function(name, def) {
  var err, p;
  p = './fixtures/' + name;
  try {
    return require(p);
  } catch (_error) {
    err = _error;
    console.log('WARN: getData():', err.message);
    return def || {};
  }
};

writeOut = function(path, data) {
  path = 'spec/fixtures/' + path;
  if (!noflo.isBrowser()) {
    return fs.writeFileSync(path, JSON.stringify(data));
  }
};

writePNG = function(path, canvas) {
  var out, stream;
  path = 'spec/fixtures/' + path;
  out = fs.createWriteStream(path);
  if (!noflo.isBrowser()) {
    stream = canvas.pngStream();
    stream.on('data', function(chunk) {
      return out.write(chunk);
    });
    return stream.on('end', function() {
      return console.log('Saved PNG file in', path);
    });
  }
};

exports.getData = getData;

exports.writeOut = writeOut;

exports.writePNG = writePNG;

exports.getCanvasWithImage = getCanvasWithImage;

exports.getCanvasWithImageNoShift = getCanvasWithImageNoShift;
