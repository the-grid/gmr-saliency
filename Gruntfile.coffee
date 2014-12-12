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
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'
      test_sets:
        options:
          bare: true
        expand: true
        cwd: 'test_set_app'
        src: ['**/*.coffee']
        dest: 'test_set_app'
        ext: '.js'

    # BDD tests
    cafemocha:
      src: ['spec/*.coffee']
      options:
        reporter: 'spec'

    # Coding standards
    coffeelint:
      components: ['Gruntfile.coffee', 'spec/*.coffee', 'test_set_app/*.coffee']
      options:
        'max_line_length':
          'level': 'ignore'

  @registerTask 'make', 'Compile GMR Saliency', () ->
    execSync 'make clean; make'

  @registerTask 'test_set', 'Test a set of images', () ->
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
          execSync './gmr-saliency ' + abspath
          console.log ' ' + abspath + ' finished.'
          data[set].push abspath

    grunt.file.write './test_set_app/data.js', 'window.DATA = {sets:' + JSON.stringify(data, 1, 1) + '};'

  @registerTask 'test', 'Build and run automated tests', () =>
    @task.run 'coffeelint'
    @task.run 'coffee:spec'
    @task.run 'cafemocha'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-contrib-coffee'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-coffeelint'

  # @registerTask 'test', ['test_sets']
  @registerTask 'default', ['make', 'coffee', 'test']

