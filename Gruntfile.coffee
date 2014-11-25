fs = require 'fs'
execSync = require('exec-sync')

test_path = './test_set/'
test_sets = ['Text', 'NonText']

module.exports = ->
  grunt = @

  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # CoffeeScript compilation
    coffee:
      test_sets:
        options:
          bare: true
        expand: true
        cwd: 'test_set_app'
        src: ['**/*.coffee']
        dest: 'test_set_app'
        ext: '.js'

  @registerTask 'make', 'Compile GMR Saliency', () ->
    execSync 'make clean; make'

  @registerTask 'test_sets', 'Test a set of images', () ->
    data = {}
    for set in test_sets
      console.log 'Testing set ' + set
      data[set] = []
      dir = test_path + set

      imgs = fs.readdirSync dir
      for img in imgs
        unless /saliency|DS_Store/.test img
          abspath = dir + '/' + img
          console.log ' ' + abspath
          execSync './out ' + abspath
          console.log ' ' + abspath + ' finished.'
          data[set].push abspath

    grunt.file.write './test_set_app/data.js', 'window.DATA = {sets:' + JSON.stringify(data, 1, 1) + '};'

  @loadNpmTasks 'grunt-contrib-coffee'

  @registerTask 'test', ['test_sets']
  @registerTask 'default', ['make', 'coffee', 'test']

