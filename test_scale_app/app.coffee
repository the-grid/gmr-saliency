document.addEventListener 'DOMContentLoaded', ->
  render()
  draw()

render = () ->
  renderer = ECT({ root : './views' , open:"{{", close:"}}"})
  data = window.DATA
  html = renderer.render('template.ect', data)
  document.getElementById('mount').innerHTML = html

draw = () ->
  for img, i in window.DATA.sets.Grid
    canvas = document.getElementById 'canvas_' + i
    context = canvas.getContext '2d'
    image = document.getElementById 'img_' + i
    console.log 'image', image
    context.drawImage image, 0, 0

    # width = canvas.width = image.width
    # height = canvas.height = image.height
    context.drawImage(image, 0, 0, image.width, image.height)

    #   polygon = img.measurements.saliency.polygon
    #   console.log polygon
    #   # Draw points of polygon
    #   for i in [0..polygon.length]
    #     point = polygon[i]

    #     context.beginPath()
    #     context.arc(point[0], point[1], 2, 0, 2 * Math.PI, false)
    #     context.fillStyle = 'rgba(255, 255, 255, 0.9)'
    #     context.fill()
      

    #   context.beginPath()
    #   context.moveTo(polygon[0][0], polygon[0][1])
    #   for i in [1..polygon.length]
    #     point = polygon[i]

    #     context.lineTo(point[0], point[1])

    #   context.fillStyle = 'rgba(0, 255, 0, 0.5)'
    #   context.fill()

      # Draw
      
    #image.src = 'National_Museum_of_Nature_and_Science-Ueno_Park-Ueno_Tokyo.jpg'


