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
        globals: ['console','casper']
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
        options: {},
        // removes failure image
        // runs casperjs tests
        // opens a new failure image if tests fail
        command: 'rm -f tests/failure.png; casperjs test tests || open tests/failure.png'
      }
    },

    // Monitor file changes
    watch: {
      scripts: {
        files: ['tests/**/*.coffee','app/**/*'],
        tasks: ['coffeelint','coffee_jshint']
      },
    }
  });

  // Load the plugin that provides the tasks
  grunt.loadNpmTasks('grunt-coffee-jshint');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default task(s)
  grunt.registerTask('default', ['coffeelint','coffee_jshint','shell']);

};