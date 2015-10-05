fs = require 'fs'
execSync = require('child_process').execSync

test_path = './test_set/'
#test_sets = ['Text', 'NonText']
test_sets = ['good', 'bad']

module.exports = ->
  grunt = @

  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Updating the package manifest files
    noflo_manifest:
      update:
        files:
          'component.json': ['graphs/*', 'components/*']
          'package.json': ['graphs/*', 'components/*']

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
      test_scale:
        options:
          bare: true
        expand: true
        cwd: 'test_scale_app'
        src: ['**/*.coffee']
        dest: 'test_scale_app'
        ext: '.js'
      root:
        options:
          bare: true
        expand: true
        cwd: '.'
        src: ['**.coffee']
        dest: '.'
        ext: '.js'

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'components/*.coffee']
      tasks: ['test']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'

    # Coding standards
    coffeelint:
      components: ['components/*.coffee', 'Gruntfile.coffee', 'spec/*.coffee', 'test_set_app/*.coffee']
      options:
        'max_line_length':
          'level': 'ignore'

    # Compiles GMR Saliency C++ code using node-gyp
    gyp:
      saliency:
        command: 'rebuild'

    # GMR Saliency doesn't has itself as dependency, so
    # for tests, symlink the executable
    symlink:
      options:
        overwrite: true
      explicit:
        src: 'build/Release/saliency'
        dest: 'node_modules/.bin/saliency'

  @registerTask 'test_set', 'Test a set of images', () ->
    data = {}
    for set in test_sets
      console.log 'Testing set ' + set
      data[set] = []
      dir = test_path + set

      imgs = fs.readdirSync dir
      for img in imgs
        unless /filtered|threshold|contours|saliency|histogram_saliency|DS_Store/.test img
          img = img.replace /\s/g, '\\ '
          abspath = dir + '/' + img
          console.log ' ' + abspath
          output = execSync './build/Release/saliency ' + abspath
          console.log ' ' + abspath + ' finished.'
          data[set].push
            image: abspath
            measurement: JSON.parse output

    grunt.file.write './test_set_app/data.js', 'window.DATA = {sets:' + JSON.stringify(data, 1, 1) + '};'

  @registerTask 'test_scale', 'Test if saliency performs well with scaled images', () ->
    data = {}
    for set in test_sets
      console.log 'Testing set ' + set
      data[set] = []
      dir = test_path + set

      imgs = fs.readdirSync dir
      for img in imgs
        unless /filtered|threshold|contours|saliency|DS_Store/.test img
          img = img.replace /\s/g, '\\ '
          abspath = dir + '/' + img
          console.log ' ' + abspath
          output = execSync 'node measure_image.js ' + abspath
          console.log ' ' + abspath + ' finished.'
          console.log output
          data[set].push
            image: abspath
            measurement: JSON.parse output

    grunt.file.write './test_scale_app/data.js', 'window.DATA = {sets:' + JSON.stringify(data, 1, 1) + '};'

  @registerTask 'test', 'Build and run automated tests', () =>
    @task.run 'gyp'
    @task.run 'symlink'
    @task.run 'coffeelint'
    @task.run 'noflo_manifest'
    @task.run 'coffee:spec'
    @task.run 'cafemocha'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-noflo-manifest'
  @loadNpmTasks 'grunt-contrib-coffee'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-node-gyp'
  @loadNpmTasks 'grunt-contrib-symlink'

  @registerTask 'test_app', ['test_sets']
  @registerTask 'default', ['test']

