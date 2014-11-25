document.addEventListener 'DOMContentLoaded', ->
  render()

render = () ->
  renderer = ECT({ root : './views' , open:"{{", close:"}}"})
  data = window.DATA
  html = renderer.render('template.ect', data)
  document.getElementById('mount').innerHTML = html
