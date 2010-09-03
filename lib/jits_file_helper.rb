require 'fileutils'

if RUBY_PLATFORM.include? "powerpc"
    $slash='/'
elsif RUBY_PLATFORM.include? "x86_64-linux"
    $slash='/'
else
    $slash="\\"
end


def clean_files(dir, &block)
  Dir.foreach(dir+$slash) { |filename| 
      next if filename == "." || filename == ".."
     
      if File.file?(dir +$slash+ filename)
          res = block.call(dir +$slash+ filename)
          FileUtils.rm_r dir +$slash+ filename, :force => true if res
      else
        clean_files(dir+$slash+filename, &block)
      end

    }
end

def clean_folders(dir, &block)
    Dir.foreach(dir+$slash) { |filename| 
      next if filename == "." || filename == ".."
     
      unless File.file?(dir +$slash+ filename)
        res = block.call(dir +$slash+ filename)
        if res
          FileUtils.rm_r dir +$slash+ filename, :force => true
        else
          clean_folders(dir+$slash+filename, &block)
        end
      end
    }
    #rescue
    #end
  end
  
  def clean_versioning(dir)
    clean_folders(dir){ |path|
        if(path.include?(".svn"))
          true
        else
         false
        end
    }
  end
  def clean_project(dir)
    clean_files(dir){ |path|
        if(path.include?(".project"))
          true
        else
         false
        end
    }
  end