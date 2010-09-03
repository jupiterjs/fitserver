require 'net/ftp'
class FtpFile
  def initialize(text)
    @text = text
    components = text.split(' ',9)
    @permissions = components[0]
    @name = components[8]
    @new_file = false
  end
  def directory?
    @permissions[0,1] == 'd'
  end
  def name
    @name
  end
  def self.get_files(ftp, new_file_name = nil)
    ftp_array = Array.new
    for file in ftp.list()
      ftp_file = FtpFile.new(file)
      ftp_file.set_as_new_file if ftp_file.name == new_file_name
      ftp_array.push(ftp_file)
    end
    @@files =  ftp_array
    ftp_array
  end
  def self.exists?(name)
    for file in @@files
      return true if file.name == name
    end
    return false
  end
  def set_as_new_file
    @new_file = true
  end
  def to_json(option = nil)
    { :name => name, 
      :type => (directory? ? 'directory': 'file' ), 
      :new_file => (@new_file ? true : false) }.to_json
  end
  def self.get_dir(path)
    return '/' if path == '/'
    folders = path.split('/')
    folders.pop
    return '/' if folders.length == 1 && folders[0] == ""
    return folders.join('/')
    
  end
  def self.set_connection(url, username, password, port=21)
    RAILS_DEFAULT_LOGGER.error('setting connection\n')
    
    connection[url] = {:users => {}} if ! connection[url]
    connection[url][:time] = Time.now
    
    thread = Thread.new {
      connection[url][:users][username] = Net::FTP.new
      connection[url][:users][username].connect(url,port)
      connection[url][:users][username].login(username,password) 
      connection[url][:users][username].passive = true
    }
    unless thread.join(7)
      thread.kill
      err = "**********\n"+Time.now.to_s+"\nTimeout Error\n"+url+"\n"
      my_file = File.new("#{RAILS_ROOT}/lib/bad_login_log.txt", 'a+')
      my_file.puts err
      my_file.close
      raise "F->IT can't connect to your server.  "+
      "Our current theory is that this is due to Suse Linux networking drivers that don't work with non-ASCI character sets.  "+
      "F->IT handles these FTP servers perfectly when running from windows."+
      "We are trying hard to figure this issue out.  If you are connecting to a US based FTP server and getting this error, please let us know!"
    end
    connection[url][:users][username]
  end
  def self.connection
    begin
      @@ftp
    rescue
      @@ftp = Hash.new
    end
    return @@ftp
  end
  
  
  def self.get_connection(session, action_name,&block)
    url = session[:url]
    username = session[:username]
    password = session[:password]
    RAILS_DEFAULT_LOGGER.error(session[:url])
    RAILS_DEFAULT_LOGGER.error('getting connection\n')

    url_hash = connection[url]
    return 'NoSession' unless url_hash
    
    
    url_hash[:time] = Time.now
    ftp = connection[url][:users][username]
    #now that we have our hopefull ftp connection, lets call the block with it
    count = 0
    begin
      count += 1
      block.call(ftp)
    rescue
      #if that doesn't work we will try again with a brand new connection ... we should check there is no connection
      puts "ERROR: "+$!.to_s
      if count < 3
        ftp.close
        ftp =FtpFile.set_connection(url, username, password)
        retry
      end
      return $!.to_s
    end
    
    clean
    
    
    return nil
  end
  
  def self.clean
    now = Time.now
    connection.delete_if {|url, hash|
        if now - hash[:time] > 30.minute
          hash[:users].each{|username,ftp| 
            begin
              ftp.close
            rescue
            end
          }
          true
        else
          false
        end
    }
  end
  
  
  def self.connections
    clean
    return connection.length
  end
end