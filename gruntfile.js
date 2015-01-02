module.exports = function(grunt) {
  
//  require('load-grunt-tasks')(grunt);
  
  // Project configuration
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <% grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        src: 'src/<%= pkg.name %>.js',
        dest: 'build/<%= pkg.name %>.min.js'
      }
    },
    shell: {
      pushBlog: {
        command: 'lftp -f lftp_ftps'
      }
    }
  });

  // Load the plugin with the uglify task
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-shell');

  grunt.registerTask('deploy-blog', ['shell']);

  // Default Task(s)
  grunt.registerTask('default', ['uglify', 'shell']);
  

};
