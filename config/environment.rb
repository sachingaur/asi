# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

#Generating secret key if it does not exist
secret_file = File.join(RAILS_ROOT, "config/session_secret")
if File.exist?(secret_file)
  secret = File.read(secret_file)
else
  secret = ActiveSupport::SecureRandom.hex(64)
  File.open(secret_file, 'w') { |f| f.write(secret) }
end


Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"

  config.gem "andand"
  config.gem "whenever", :lib => false, :source => 'http://gemcutter.org/'

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_trunk_session',
    :secret      => secret
  }


  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Environment variable part for Common Services begins here
  DB_STRING_MAX_LENGTH = 255
  PURSE_LIMIT = -10
  SERVER_DOMAIN = "http://localhost:3000"
  RESSI_URL = "http://localhost:9000"
  RESSI_TIMEOUT = 5
  RESSI_UPLOAD_HOUR = 3

  #CAS_BASE_URL = "http://cos.alpha.sizl.org:8180/cas"
  CAS_BASE_URL = "https://zeus.cs.hut.fi/cs/shib/cos"
  CAS_VALIDATE_URL = "https://zeus.cs.hut.fi/cs/shib/8888/proxyValidate"

  LOG_TO_RESSI = false

  #If following is true, created users must validate their emails before they can log in.
  VALIDATE_EMAILS = false
  REQUIRE_SSL_LOGIN = false
end

require 'render_extend'
require 'filtered_pagination'
require 'casclient'
require 'casclient/frameworks/rails/filter'
require 'casclient/frameworks/rails/cas_proxy_callback_controller'
require 'whenever'
require 'actionpack_extend'

# enable detailed CAS logging for easier troubleshooting
cas_logger = CASClient::Logger.new(RAILS_ROOT+'/log/cas.log')
cas_logger.level = Logger::DEBUG

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => CAS_BASE_URL,
  :logger => cas_logger,
  :validate_url  => "https://zeus.cs.hut.fi/cs/shib/9997/proxyValidate"
  #:proxy_retrieval_url => "https://kassi:3444/cas_proxy_callback/retrieve_pgt",
  #:proxy_callback_url => "https://kassi:3444/cas_proxy_callback/receive_pgt"
)
