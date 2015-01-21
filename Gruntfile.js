module.exports = function(grunt) {

  'use strict';

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    meta: {
      banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
    },

    jasmine: {
      javascripts: {
        src: [
          'app/assets/javascripts/modules/moj.checkbox-summary.js',
          'app/assets/javascripts/modules/moj.timeout-prompt.js'
        ],
        options: {
          vendor: [
            'node_modules/jquery-browser/lib/jquery.js',
            'node_modules/jasmine-jquery/lib/jasmine-jquery.js',
            'vendor/assets/javascripts/handlebars-v1.3.0.js'
          ],
          specs: 'spec/javascripts/*Spec.js',
          keepRunner: true
        }
      }
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
      },
      scrape: {
        options: {
          stdout: true
        },
        command: 'casperjs scripts/visiting_times.js'
      },
      yaml: {
        options: {
          stdout: true
        },
        command: 'json2yaml prison_data.json > prison_data.yaml -d 8'
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
      specs: {
        files: ['spec/javascripts/**/*.js'],
        tasks: ['jasmine']
      },
      failure: {
        files: ['tests/*.png'],
        tasks: ['notify:casperjs']
      }
    },

    jshint: {
      all: ['Gruntfile.js', 'app/assets/javascripts/**/*.js'],
      options: {
        jshintrc: '.jshintrc'
      }
    }
  });

  // Load the plugin that provides the tasks
  grunt.loadNpmTasks('grunt-coffee-jshint');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-notify');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-jasmine');

  // Default task(s)
  grunt.registerTask('default', 'Test and lint application code', ['jshint','coffeelint:app','coffee_jshint:app', 'jasmine']);
  grunt.registerTask('tests', 'run integration tests', ['coffeelint:tests','coffee_jshint:tests','shell:tests']);
  grunt.registerTask('scrape', 'scrape web for visiting times', ['shell:scrape','shell:yaml']);

};
