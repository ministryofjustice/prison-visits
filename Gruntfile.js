module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    meta: {
      banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
    },

    // Test the coffee script against JSlint
    coffee_jshint: {
      app: {
        source: {
          src: 'app/assets/javascripts/**/*'
        }
      },
      tests: {
        options: {
          globals: ['console','casper','__utils__']
        },
        source: {
          src: 'tests/**/*.coffee'
        }
      }
    },

    // Test the coffee script quality
    coffeelint: {
      options: {
        'no_trailing_whitespace': {
          'level': 'error'
        },
        'max_line_length': {
          'level': 'ignore'
        }
      },
      app: {
        files: {
          src: ['app/assets/**/*.coffee']
        }
      },
      tests: {
        files: {
          src: ['tests/**/*.coffee']
        }
      }
    },

    // Run casperjs tests via the command line
    shell: {
      tests: {
        options: {
          stdout: true
        },
        // removes failure image
        // runs casperjs tests
        // opens a new failure image if tests fail
        // command: 'rm -f tests/failure.png; casperjs test tests || open tests/failure.png'
        command: 'rm -f tests/failure.png; casperjs test tests'
      }
    },

    notify: {
      casperjs: {
        options: {
          title: 'CasperJS tests failed',  // optional
          message: 'See tests/failure.png for details', //required
        }
      }
    },

    // Monitor file changes
    watch: {
      app: {
        files: ['app/assets/javascripts/**/*'],
        tasks: ['default']
      },
      tests: {
        files: ['tests/**/*.coffee'],
        tasks: ['tests']
      },
      failure: {
        files: ['tests/*.png'],
        tasks: ['notify:casperjs']
      }
    },

    jshint: {
      all: ['Gruntfile.js', 'app/assets/javascripts/**/*.js']
    }
  });

  // Load the plugin that provides the tasks
  grunt.loadNpmTasks('grunt-coffee-jshint');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-notify');
  grunt.loadNpmTasks('grunt-contrib-jshint');

  // Default task(s)
  grunt.registerTask('default', ['jshint','coffeelint:app','coffee_jshint:app']);
  grunt.registerTask('tests', ['coffeelint:tests','coffee_jshint:tests','shell']);

};