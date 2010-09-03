#Example:
#ruby script/compress_js.rb --file 'public\javascripts\JITS\JITS_Object.js'
#ruby script/compress_js.rb --folder 'public\JsJ'
require 'getoptlong'


require 'lib/jits_file_helper.rb'


FileUtils.cp_r File.join('..','jmvc','jmvc','.'), 
                      File.join('public','3_0','jmvc')
                      
clean_versioning(File.join('public','3_0','jmvc'))
clean_project(File.join('public','3_0','jmvc'))


FileUtils.cp_r File.join('..','jmvc','jquery','.'), 
                      File.join('public','3_0','jquery')
                      
clean_versioning(File.join('public','3_0','jquery'))
clean_project(File.join('public','3_0','jquery'))
