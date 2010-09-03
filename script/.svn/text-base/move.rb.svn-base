#Example:
#ruby script/compress_js.rb --file 'public\javascripts\JITS\JITS_Object.js'
#ruby script/compress_js.rb --folder 'public\JsJ'
require 'getoptlong'


require 'lib/jits_file_helper.rb'

print "copying"
FileUtils.cp_r File.join('..','ftp',"."), 
                      File.join('..','fer')
print "cleaning versioning"                 
clean_versioning(File.join('..','fer'))
print "cleaning project"  
clean_project(File.join('..','fer'))
