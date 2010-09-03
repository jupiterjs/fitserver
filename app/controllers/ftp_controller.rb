require 'tempfile'
require 'ftp_file.rb'
require 'json'
class FtpController < ApplicationController
  #returns text from a file
  def client
    params[:env] = params[:env] || ENV['RAILS_ENV']
    render :layout => false
  end
  
  def setConnection
    session[:url] = params[:url].strip
    session[:username] = params[:username].strip
    session[:password] = params[:password].strip
    session[:port] = (params[:port] || "21").strip
    FtpFile.set_connection(session[:url],session[:username],session[:password],session[:port].to_i)
  end
#  def open
#     text = ''
#    @response_action = FtpFile.get_connection(session, 'Open') do |ftp|
#      ftp.retrlines("RETR " + params[:path]) do |line|
#          text << line +"\n"
#      end
#    end
#    render( :text => text)
#  end
  
  def index
    session[:url] = nil
    session[:username] = nil
    session[:password] = nil
    render :layout=> false
  end
  
  def connect
    begin
      setConnection
      redirect_to :action => 'client', :env => params[:env]
    rescue
      err = "**********\n"+Time.now.to_s+"\n"+$!.to_s+params[:url].strip+"\n"
      my_file = File.new("#{RAILS_ROOT}/lib/bad_login_log.txt", 'a+')
      my_file.puts err
      my_file.close
      render( :text => $!.to_s)
    end
  end
  def run
    if !session[:url]
      return render(:status => 400, :text => {:response =>'NoSession'}.to_json )
    end
    
    commands = JSON.parse(params['commands'])
    p commands
    result = {}
    error = FtpFile.get_connection(session, 'Dir') do |ftp|
      commands.each {|command|
        args = [command["method"]].concat(command["params"] || [])
        puts "RUNNING "+command["method"]+"("+(command["params"] || []).join(",")+")"
        if command["method"] == "retrlines"
          res = ""
          ftp.send(*args) do |line|
            res << line +"\n"
            res = res.toutf8
          end
        elsif command["method"] == "storlines"
          puts "storing lines "
          Tempfile.open('tmps') do |f| 
            f << command["params"][1] 
            f.rewind
            ftp.storlines(command["params"][0] , f )
          end
        else
          puts("executing")
          res = ftp.send(*args)
          p res
        end
        result[command["result"]] = res if(command["result"])
      }
    end
    if error
      render( { :status => 400, :text => {:error => error}.to_json } )
    else
      render( :text =>
        result.to_json
      )
    end
    
  end
#  def dir
#    if !session[:url]
#      return render( :text => {:response =>'NoSession'}.to_json )
#    end
#    params[:path] = '/' unless params[:path]
#    files_array = nil
#    @response_action = FtpFile.get_connection(session, 'Dir') do |ftp|
#      ftp.voidcmd("CWD "+params[:path])
#      files_array = FtpFile.get_files(ftp)
#    end
#    if @response_action
#      render( { :status => 400, :text => {:error => "Can't open "+params[:path], :response => @response_action}.to_json } )
#    else
#      render( :text =>
#        {:response => 'Dir', 
#        :directory => params[:path], 
#        :files => files_array}.to_json
#      )
#    end
#    
#  end
  
  
  
  
#  def save
#    text = params[:text]
#    @response_action = FtpFile.get_connection(session, 'Save') do |ftp|
#      Tempfile.open('tmps') do |f| 
#        f << text 
#        f.rewind
#        ftp.storlines( "STOR "+ params[:path], f )
#      end
#    end
#    if @response_action
#      render( { :status => 400, :text => {:error => "Can't open "+params[:path], :response => @response_action} } )
#    else
#      render( :text => {:response => "Save", :path => params[:path]}.to_json )
#    end
#  end
  
#  def new_file
#    root = 'untitled'
#    ending = '.html'
#    params[:path] = '/' unless params[:path]
#    files_array = nil
#    file_path = nil
#    @response_action = FtpFile.get_connection(session, 'New File') do |ftp|
#        ftp.chdir(params[:path]) #change to our directory
#        files_array = FtpFile.get_files(ftp) #get the files
#        #now find where we can put it
#        file_path = root+ending
#        i = 0;
#        while FtpFile.exists?(file_path)
#          i += 1;
#          file_path = root+i.to_s+ending
#        end
#        ftp.puttextfile( File.join('lib', 'empty_file.txt'), file_path ) #save the file
#        files_array = FtpFile.get_files(ftp, file_path) #get the files again, just to be safe
#    end
#    
#    if @response_action
#      render( { :status => 400, :text => {:error => "Can't create file in "+params[:path], :response => @response_action} } )
#    else
#      render(:text => {:response => 'New File',:directory => params[:path], :files => files_array, :new_file => file_path}.to_json )
#    end
#  end
  
  
#  def new_folder
#    root = 'untitled'
#    params[:path] = '/' unless params[:path]
#    files_array = nil
#    file_path = nil
#    @response_action = FtpFile.get_connection(session, 'New Folder') do |ftp|
#        ftp.chdir(params[:path]) #change to our directory
#        files_array = FtpFile.get_files(ftp) #get the files
#        #now find where we can put it
#        file_path = root
#        i = 0;
#        while FtpFile.exists?(file_path)
#          i += 1;
#          file_path = root+i.to_s
#        end
#        ftp.mkdir( file_path ) #save the file
#        files_array = FtpFile.get_files(ftp, file_path) #get the files again, just to be safe
#    end  
#    if @response_action
#      render( { :status => 400, :text => {:error => "Can't create folder in "+params[:path], :response => @response_action} } )
#    else
#      render(:text => {:response =>'New Folder',:directory => params[:path], :files => files_array, :new_file => file_path}.to_json )
#    end
#  end
  
  
#  def rename_file
#    from_path = params[:from_path]
#    to_path = params[:to_path]
#    directory = FtpFile.get_dir(to_path)
#    files_array = nil
#    @response_action = FtpFile.get_connection(session, 'Renamed File') do |ftp|
#      ftp.rename(from_path, to_path)
#      folder = to_path.split("/")
#      folder.pop
#      ftp.chdir(directory)
#      files_array = FtpFile.get_files(ftp, to_path.split("/").pop)
#    end
#    if @response_action
#      render( { :status => 400, :text => {:error => "Can't create folder in "+params[:path], :response => @response_action }.to_json } )
#    else
#      render(:text => {:response => @response_action, :from_path => from_path, :to_path => to_path, :directory => directory, :files => files_array}.to_json)
#    end
#  end
  
#  def rename_folder
#    from_path = params[:from_path]
#    to_path = params[:to_path]
#    directory = FtpFile.get_dir(to_path)
#    files_array = nil
#    @response_action = FtpFile.get_connection(session, 'Renamed Folder') do |ftp|
#      ftp.rename(from_path, to_path)
#      ftp.chdir(directory)
#      files_array = FtpFile.get_files(ftp, to_path.split("/").pop)
#    end
#    if @response_action
#      render( { :status => 400, :text => {:error => "Can't rename folder "+params[:path], :response => @response_action }.to_json } )
#    else
#      render(:text => {:response => 'Renamed Folder', :from_path => from_path, :to_path => to_path, 
#              :directory => directory, :files => files_array}.to_json)
#    end
#  end
  
  # we should be checking the params
#  def delete_file
#    @response_action = FtpFile.get_connection(session, 'Delete File') do |ftp|
#      ftp.delete(params[:path])
#    end
#    if @response_action
#      render( { :status => 400, :text => {:error => "Can't delete file "+params[:path], :response => @response_action }.to_json } )
#    else
#      render(:text => {:response => 'Delete File', :path => params[:path] }.to_json )
#    end
#  end
#  def delete_folder
#    force = params[:force]
#    @response_action = FtpFile.get_connection(session, 'Delete Folder') do |ftp|
#      ftp.rmdir(params[:path])
#    end
#    if @response_action
#      render( { :status => 400, :text => {:error => "Can't delete folder "+params[:path], :response => @response_action }.to_json } )
#    else
#      render(:text => {:response => 'Delete Folder', :path => params[:path] }.to_json )
#    end
#  end
  #takes a path, returns files and folders
  def download
    text = ''
    @response_action = FtpFile.get_connection(session, 'Download') do |ftp|
      ftp.retrlines("RETR " + params[:path].join('/')) do |line|
          text << line +"\n"
      end
      
      send_data text, :filename =>  params[:path].last
    end
    if @response_action
      render( { :status => 400, :text => {:error => "Can't download "+params[:path], :response => @response_action }.to_json } )
    end
  end
  
  def connections
    
  end
  
end