var draw, render;

document.addEventListener('DOMContentLoaded', function() {
  render();
  return draw();
});

render = function() {
  var data, html, renderer;
  renderer = ECT({
    root: './views',
    open: "{{",
    close: "}}"
  });
  data = window.DATA;
  html = renderer.render('template.ect', data);
  return document.getElementById('mount').innerHTML = html;
};

draw = function() {
  var canvas, context, i, image, img, _i, _len, _ref, _results;
  _ref = window.DATA.sets.Grid;
  _results = [];
  for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
    img = _ref[i];
    canvas = document.getElementById('canvas_' + i);
    context = canvas.getContext('2d');
    image = document.getElementById('img_' + i);
    console.log('image', image);
    context.drawImage(image, 0, 0);
    _results.push(context.drawImage(image, 0, 0, image.width, image.height));
  }
  return _results;
};
