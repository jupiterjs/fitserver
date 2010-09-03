require 'ftp_file.rb'
class UploadController < ApplicationController
  session :cookie_only => false, :only => :index
  
  def index
    p params[:folder]
    @path = params[:folder]
    @path = '/' unless @path
    p params[:Filedata].size
    if params[:Filedata].size > 10000000
      @response_action = 'All files must be less than 10 MB'
      return
    end
    @response_action = FtpFile.get_connection(session, 'Upload') do |ftp|
      p "changing"
      ftp.chdir(@path)
      p "changed"
      Tempfile.open('tmps') do |f| 
        f.write(params[:Filedata].read)
        p "wrote data"
        f.rewind
        p "wrote to temp"
        ftp.storbinary( "STOR "+ params[:Filedata].original_filename, f, 1024, nil )
        p "stor in place"
      end
      @files_array = FtpFile.get_files(ftp)
    end
    render( :text => 'worked')
  end

  
end