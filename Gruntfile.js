module.exports = function(grunt) {

  //Initializing the configuration object
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    // Build SCSS files
    sass: {
      dist: {
        options: {
          sourceMap: true,
          sourceComments: false,
          includePaths: ['public/web/assets/scss'],
          outputStyle: "compressed"
        },
        files: {
          'public/web/assets/css/screen.min.css': 'public/web/assets/scss/screen.scss',
          'public/web/assets/css/print.min.css': 'public/web/assets/scss/print.scss'
        }
      },
      dev: {
        options: {
          sourceMap: true,
          sourceComments: true,
          includePaths: ['public/web/assets/scss'],
          outputStyle: "nested"
        },
        files: {
          'public/web/assets/css/screen.css': 'public/web/assets/scss/screen.scss',
          'public/web/assets/css/print.css': 'public/web/assets/scss/print.scss'
        },
        
      }
    },

    // Allow sass globbing
    sass_globbing: {
      all: {
        files: {
          'public/web/assets/scss/utilities/_pages.scss': 'public/web/assets/scss/pages/**/*.scss'
        }
      }
    },

    // Concatenate and minify CSS
    cssmin: {
      vendor: {
        options: {
          sourceMap: true
        },
        files: {
          'public/web/assets/css/vendor.min.css': [
            'bower_components/FlexSlider/flexslider.css',
            'bower_components/magnific-popup/dist/magnific-popup.css'
          ]
        }
      }
    },

    // Split CSS
    csssplit: {
      dev: {
        src: ['public/web/assets/css/screen.min.css'],
        dest: 'public/web/assets/css/screen.css',
        options: {
          maxSelectors: 4095,
          maxPages: 1,
          suffix: '_page'
        }
      },
    },

    // Concatenate and compress JS
    uglify: {

      // Vendor libraries
      vendor: {
        options: {
          mangle: false,
          sourceMap: true,
          sourceMapName: 'public/web/assets/js/dist/vendor.min.map'
        },
        files: {
          'public/web/assets/js/dist/vendor.min.js': [

            // Core libs
            'bower_components/html5shiv/dist/html5shiv.js',
            'bower_components/respond/dest/respond.src.js',
            'bower_components/eventEmitter/EventEmitter.js',
            'bower_components/jquery/dist/jquery.js',

            // Bootstrap JS
            'bower_components/bootstrap-sass/assets/javascripts/bootstrap/affix.js',
            'bower_components/bootstrap-sass/assets/javascripts/bootstrap/alert.js',
            //'bower_components/bootstrap-sass/assets/javascripts/bootstrap/button.js',
            //'bower_components/bootstrap-sass/assets/javascripts/bootstrap/carousel.js',
            'bower_components/bootstrap-sass/assets/javascripts/bootstrap/collapse.js',
            'bower_components/bootstrap-sass/assets/javascripts/bootstrap/dropdown.js',
            //'bower_components/bootstrap-sass/assets/javascripts/bootstrap/modal.js',
            //'bower_components/bootstrap-sass/assets/javascripts/bootstrap/popover.js',
            //'bower_components/bootstrap-sass/assets/javascripts/bootstrap/scrollspy.js',
            //'bower_components/bootstrap-sass/assets/javascripts/bootstrap/tab.js',
            //'bower_components/bootstrap-sass/assets/javascripts/bootstrap/tooltip.js',
            'bower_components/bootstrap-sass/assets/javascripts/bootstrap/transition.js',

            // Other JS libs
            'bower_components/parsleyjs/dist/parsley.js',
            'bower_components/jquery.easing/js/jquery.easing.js',
            'bower_components/jquery-placeholder/jquery.placeholder.js',
            'bower_components/imagesloaded/imagesloaded.js',
            'bower_components/magnific-popup/dist/jquery.magnific-popup.js',
            'bower_components/FlexSlider/jquery.flexslider.js'
          ]
        }
      },

      // Custom code
      core: {
        options: {
          mangle: false,
          sourceMap: true,
          sourceMapName: 'public/web/assets/js/dist/core.min.map',
          banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %> */'
        },
        files: {
          'public/web/assets/js/dist/core.min.js': [
            'public/web/assets/js/core.js'
          ],
        }
      }
      
    },

    // Cache bust
    cacheBust: {
      options: {
        encoding: 'utf8',
        algorithm: 'md5',
        length: 16,
        rename: false,
        enableUrlFragmentHint: true,
        baseDir: './public/'
      },
      assets: {
        files: [{
          expand: true,
          baseDir: './public/',
          src: [
            'fuel/app/views/**/*.twig',
            'fuel/app/views/**/*.html',
            'fuel/app/views/**/*.php',
            'public/cuts/**/*.html',
            'public/cuts/**/*.php',
            'public/web/assets/**/screen.min.css',
            'public/web/assets/**/print.min.css'
          ]
        }]
      }
    },

    // Build sprite file
    sprite: {
      all: {
        src: 'public/web/assets/images/sprites/**/*.png',
        dest: 'public/web/assets/images/sprite.png',
        destCss: 'public/web/assets/scss/utilities/_sprites.scss',
        cssTemplate: 'public/web/assets/scss/utilities/sprites.template.mustache',
        padding: 2,
        algorithm: 'binary-tree'
      }
    },

    // Build sprite file
    sprite: {
      all: {
        src: 'public/web/assets/images/sprites/**/*.png',
        dest: 'public/web/assets/images/sprite.png',
        destCss: 'public/web/assets/scss/utilities/_sprites.scss',
        cssTemplate: 'public/web/assets/scss/utilities/sprites.template.handlebars',
        padding: 2,
        algorithm: 'binary-tree',
        retinaSrcFilter: ['public/web/assets/images/sprites/**/*@2x.png'],
        retinaDest: 'public/web/assets/images/sprite@2x.png',
        imgPath: '../images/sprite.png',
        retinaImgPath: '../images/sprite@2x.png'
      }
    },

    // Copy vendor files
    copy: {
      fonts: {
        expand: true,
        src: [
          'bower_components/fontawesome/fonts/**/*.{eot,svg,ttf,woff,woff2}',
          'bower_components/FlexSlider/fonts/**/*.{eot,svg,ttf,woff,woff2}',
          'bower_components/bootstrap-sass/**/*.{eot,svg,ttf,woff,woff2}'
        ],
        dest: 'public/web/assets/fonts/',
        flatten: true,
        filter: 'isFile',
      },
    },

    // Watch task
    watch: {
      options: {
        livereload: true
      },
      sass: {
        files: ['public/web/assets/scss/**/*.scss'],
        tasks: ['sass_globbing', 'sass:dist']
      },
      sprite: {
        files: ['public/web/assets/images/sprites/**/*.png'],
        tasks: ['sprite']
      },
      vendorjs: {
        files: ['bower_components/**/*.js'],
        tasks: ['uglify:vendor']
      },
      corejs: {
        files: ['public/web/assets/js/**/*.js', '!public/web/assets/js/dist/*.js'],
        tasks: ['uglify:core']
      },
      vendorcss: {
        files: ['bower_components/**/*.css'],
        tasks: ['cssmin:vendor']
      },
      vendorfonts: {
        files: ['public/components/**/*.{eot,svg,ttf,woff,woff2}'],
        tasks: ['copy:fonts']
      }
    }

  });

  // Plugin loading
  grunt.loadNpmTasks('grunt-spritesmith');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-sass-globbing');
  grunt.loadNpmTasks('grunt-cache-bust-alt');
  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-csssplit');
  grunt.loadNpmTasks('grunt-hub');

  // Task definition
  grunt.registerTask('dist', ['sprite', 'sass_globbing', 'sass:dist', 'csssplit:dev', 'uglify:vendor', 'uglify:core', 'cssmin:vendor', 'copy:fonts', 'cacheBust']);
  grunt.registerTask('dev', ['dist', 'watch']);
  grunt.registerTask('default', ['dev']);

};