var render;

document.addEventListener('DOMContentLoaded', function() {
  return render();
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
