# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { 
    :session_key => '_ftp_session_id', 
    :secret      => '118939c37d94574e284ded8437d4ea8456dae24cc5bda61d8eaf2731d49273bc4c620' 
  }
  
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :active_record ]
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

AppConfig.setup


# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

#ActionController::Base.session_options[:cookie_only] = false
class CGI::Session
  alias original_initialize initialize
  def initialize(request, option = {})
    session_key = option['session_key'] || '_session_id'
    query_string = if (qs = request.env_table["QUERY_STRING"]) and qs != ""
      qs
    elsif (ru = request.env_table["REQUEST_URI"][0..-1]).include?("?")
      ru[(ru.index("?") + 1)..-1]
    end
    if query_string and query_string.include?(session_key)
      option['session_data'] = CGI.unescape(query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first)
    end
    original_initialize(request, option)
  end
end

class CGI::Session::CookieStore
  alias original_initialize initialize
  def initialize(session, options = {})
    @session_data = options['session_data']
    original_initialize(session, options)
  end

  def read_cookie
    @session_data || @session.cgi.cookies[@cookie_options['name']].first
  end
end



# Include your application configuration below