module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    meta: {
      banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
    },

    // Test the coffee script against JSlint
    coffee_jshint: {
      options: {
        globals: ['console','casper','__utils__']
      },
      source: {
        src: 'tests/**/*.coffee'
      }
    },

    // Test the coffee script quality
    coffeelint: {
      tests: {
        files: {
          src: ['tests/**/*.coffee']
        },
        options: {
          'no_trailing_whitespace': {
            'level': 'error'
          },
          'max_line_length': {
            'level': 'ignore'
          }
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
      scripts: {
        files: ['tests/**/*.coffee','app/**/*'],
        tasks: ['default']
      },
      failure: {
        files: ['tests/*.png'],
        tasks: ['notify:casperjs']
      }
    }
  });

  // Load the plugin that provides the tasks
  grunt.loadNpmTasks('grunt-coffee-jshint');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-notify');

  // Default task(s)
  grunt.registerTask('default', ['coffeelint','coffee_jshint','shell']);

};