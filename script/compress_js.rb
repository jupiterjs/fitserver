#Example:
#ruby script/compress_js.rb --file 'public\javascripts\JITS\JITS_Object.js'
#ruby script/compress_js.rb --folder 'public\JsJ'
require 'getoptlong'
#require 'lib/Array_Additions.rb'
require 'fileutils'

### Program Options
progopts = GetoptLong.new(
  [ "--file","-f", GetoptLong::OPTIONAL_ARGUMENT ]
)

class String
  def chump(remove)
    if self.index(remove) == 0
      self.slice(remove.length, self.length - remove.length)
    else
      return nil
    end
  end
end

def append_file_text_to_file(file, path_to_file_to_append)
  file_to_append = File.open(path_to_file_to_append)
    file << file_to_append.read
    file << "\n"
  file_to_append.close
end

@file = 'public/test.html'
progopts.each do |option, arg|
  case option

    when '--file'
      @file = arg
    else
      puts "Unrecognized option #{opt}"
      exit 0
    end
end


def include(file)
  #open and read file
  #add file content to collection
  #look for 
end


def compressible_file?(file)
  # compressing query doesn't work correctly
  return true if(file.ends_with('.js') && !file.ends_with('query.js'))
  return false
end

def get_js(text)
  files = []
  matches = text.split(/(<script[^>]*>[^<]*<\/script>)/)
  matches.each{|m|
    match = m.match(/<script[^>]*>/)
    if match
      files += get_includes( m.gsub(/<(\/?)script[^>]*>/, '') )
    end
  }
  return files
end
def get_includes(text)
  files = []
  matches = text.split(/(includeJS\([^\)]*\))/)
  matches.each{|m|
    if m.include?('includeJS(')
      files += m['includeJS('.length, (m.length - 'includeJS('.length - 1)].gsub(/[\t\n "']/,'').split(',')
    end
  }
  return files
end

def append_file_text_to_file(file, path_to_file_to_append)
  p 'appending '+path_to_file_to_append
  file_to_append = File.open(path_to_file_to_append)
    file << file_to_append.read
    file << ";\n"
  file_to_append.close
end

return if ! @file
  
  
  
  
  file = File.open(@file)
  setup_text = file.read
  file.close
  files = get_js(setup_text)
  
  File.open(File.join('public','javascripts','production_collection.js'), 'w') do |f|
    for file in files
      file_name = file.include?('.') ? file : file+'.js'
      append_file_text_to_file(f, File.join('public',file_name))
    end
  end
  
  system('java -jar script\yuicompressor-2.2.4.jar '+File.join('public','javascripts','production_collection.js')+' -o '+
  File.join('public','javascripts','production.js'))
  





