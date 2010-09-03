class DataFile 
  
  def self.save(data, name, directory)
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path,'wb') do |file|
      file.puts data.read
    end
  end
  
end