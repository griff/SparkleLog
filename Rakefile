require 'bundler/setup'
$root = File.expand_path('..', __FILE__)
$: << File.expand_path('../lib', __FILE__)

ENV['APPCAST_URL'] ||= '/metaz/appcast.xml'

namespace :process do
  task :latest do
    first = ENV['ACCESS_LOG'] || 'log-data/www.maven-group.org-access.log'
    raise "Invalid file #{first}" unless File.exist?(first)
    sh "cat #{first} | #{$root}/bin/access_log"
    if File.exist?("#{first}.1")
      sh "cat #{first}.1 | #{$root}/bin/access_log"
    end
  end

  task :all => :latest do
    first = ENV['ACCESS_LOG'] || 'log-data/www.maven-group.org-access.log'
    raise "Invalid file #{first}" unless File.exist?(first)
    Dir["#{first}.*.gz"].each do |filename|
      sh "gunzip -c #{filename} | #{$root}/bin/access_log"
    end
  end
end

namespace :transfer do
  task :latest do
    sh "scp zev.maven-group.org:/var/log/apache2/www.maven-group.org-access.log log-data/"
    sh "scp zev.maven-group.org:/var/log/apache2/www.maven-group.org-access.log.1 log-data/"
  end

  task :all do
    sh "scp zev.maven-group.org:/var/log/apache2/www.maven-group.org-access.log* log-data/"
  end
end

namespace :export do
  task :percent do
    sh "#{$root}/bin/export", 'percent', "#{$root}/public/percent.json"
  end
  task :support do
    sh "#{$root}/bin/export", 'support',  "#{$root}/public/support.json"
  end
  task :all_versions do
    sh "#{$root}/bin/export", 'all', "#{$root}/public/all.json"
  end
  task :version, :v do |t, args|
    version = args[:v]
    raise "Missing version specify eg. version[1.0.0]" unless version
    make_version(version)
  end

  def make_version(version)
    sh "#{$root}/bin/export", version, "#{$root}/public/#{version}.json"
  end

  task :all => [:percent, :support, :all_versions] do
    make_version('10.5')
    make_version('10.6')
    make_version('10.7')
    make_version('10.8')
    make_version('10.9')
  end
end

namespace :geoip do
  task :update do
    mkdir_p "data"
    cd 'data' do
      sh "curl -O -f -z GeoLiteCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"
      sh "gunzip -c GeoLiteCity.dat.gz > GeoLiteCity.dat"
    end
  end
end

require 'sinatra/activerecord/rake'
require './app'

=begin comment
db_namespace = namespace :db do
  task :load_config do
    ActiveRecord::Migrator.migrations_paths = File.join(Rails.root, 'db', 'migrate')
  end

  task :environment => :load_config do
    ActiveRecord::Base.establish_connection(configs_for_environment.first)
  end
  
  desc 'Create the database from config/database.yml for the current Rails.env (use db:create:all to create all dbs in the config)'
  task :create => :load_config do
    configs_for_environment.each { |config| create_database(config) }
    ActiveRecord::Base.establish_connection(configs_for_environment.first)
  end
  
  def create_database(config)
    if File.exist?(config['database'])
      $stderr.puts "#{config['database']} already exists"
    else
      begin
        # Create the SQLite database
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection
      rescue Exception => e
        $stderr.puts e, *(e.backtrace)
        $stderr.puts "Couldn't create database for #{config.inspect}"
      end
    end
  end

  desc 'Drops the database for the current Rails.env (use db:drop:all to drop all databases)'
  task :drop => :load_config do
    configs_for_environment.each { |config| drop_database_and_rescue(config) }
  end

  desc "Migrate the database (options: VERSION=x, VERBOSE=false)."
  task :migrate => [:environment, :load_config] do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
      ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
    end
    db_namespace['_dump'].invoke
  end

  task :_dump do
    case ActiveRecord::Base.schema_format
    when :ruby then db_namespace["schema:dump"].invoke
    when :sql  then db_namespace["structure:dump"].invoke
    else
      raise "unknown schema format #{ActiveRecord::Base.schema_format}"
    end
    # Allow this task to be called as many times as required. An example is the
    # migrate:redo task, which calls other two internally that depend on this one.
    db_namespace['_dump'].reenable
  end

  namespace :migrate do
    # desc  'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo => [:environment, :load_config] do
      if ENV['VERSION']
        db_namespace['migrate:down'].invoke
        db_namespace['migrate:up'].invoke
      else
        db_namespace['rollback'].invoke
        db_namespace['migrate'].invoke
      end
    end

    # desc 'Resets your database using your migrations for the current environment'
    task :reset => ['db:drop', 'db:create', 'db:migrate']

    # desc 'Runs the "up" for a given migration VERSION.'
    task :up => [:environment, :load_config] do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_paths, version)
      db_namespace['_dump'].invoke
    end

    # desc 'Runs the "down" for a given migration VERSION.'
    task :down => [:environment, :load_config] do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      ActiveRecord::Migrator.run(:down, ActiveRecord::Migrator.migrations_paths, version)
      db_namespace['_dump'].invoke
    end

    desc 'Display status of migrations'
    task :status => [:environment, :load_config] do
      config = ActiveRecord::Base.configurations[Rails.env || 'development']
      ActiveRecord::Base.establish_connection(config)
      unless ActiveRecord::Base.connection.table_exists?(ActiveRecord::Migrator.schema_migrations_table_name)
        puts 'Schema migrations table does not exist yet.'
        next  # means "return" for rake task
      end
      db_list = ActiveRecord::Base.connection.select_values("SELECT version FROM #{ActiveRecord::Migrator.schema_migrations_table_name}")
      file_list = []
      ActiveRecord::Migrator.migrations_paths.each do |path|
        Dir.foreach(path) do |file|
          # only files matching "20091231235959_some_name.rb" pattern
          if match_data = /^(\d{14})_(.+)\.rb$/.match(file)
            status = db_list.delete(match_data[1]) ? 'up' : 'down'
            file_list << [status, match_data[1], match_data[2].humanize]
          end
        end
      end
      db_list.map! do |version|
        ['up', version, '********** NO FILE **********']
      end
      # output
      puts "\ndatabase: #{config['database']}\n\n"
      puts "#{'Status'.center(8)}  #{'Migration ID'.ljust(14)}  Migration Name"
      puts "-" * 50
      (db_list + file_list).sort_by {|migration| migration[1]}.each do |migration|
        puts "#{migration[0].center(8)}  #{migration[1].ljust(14)}  #{migration[2]}"
      end
      puts
    end
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => [:environment, :load_config] do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
    db_namespace['_dump'].invoke
  end

  # desc 'Pushes the schema to the next version (specify steps w/ STEP=n).'
  task :forward => [:environment, :load_config] do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.forward(ActiveRecord::Migrator.migrations_paths, step)
    db_namespace['_dump'].invoke
  end

  # desc 'Drops and recreates the database from db/schema.rb for the current environment and loads the seeds.'
  task :reset => :environment do
    db_namespace["drop"].invoke
    db_namespace["setup"].invoke
  end

  # desc "Retrieves the charset for the current environment's database"
  task :charset => :environment do
    config = ActiveRecord::Base.configurations[Rails.env || 'development']
    case config['adapter']
    when /mysql/
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.charset
    when /postgresql/
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.encoding
    when /sqlite/
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.encoding
    else
      $stderr.puts 'sorry, your database adapter is not supported yet, feel free to submit a patch'
    end
  end

  # desc "Retrieves the collation for the current environment's database"
  task :collation => :environment do
    config = ActiveRecord::Base.configurations[Rails.env || 'development']
    case config['adapter']
    when /mysql/
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.collation
    else
      $stderr.puts 'sorry, your database adapter is not supported yet, feel free to submit a patch'
    end
  end

  desc 'Retrieves the current schema version number'
  task :version => :environment do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  # desc "Raises an error if there are pending migrations"
  task :abort_if_pending_migrations => :environment do
    pending_migrations = ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations_paths).pending_migrations

    if pending_migrations.any?
      puts "You have #{pending_migrations.size} pending migrations:"
      pending_migrations.each do |pending_migration|
        puts '  %4d %s' % [pending_migration.version, pending_migration.name]
      end
      abort %{Run `rake db:migrate` to update your database then try again.}
    end
  end

  desc 'Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the db first)'
  task :setup => ['db:schema:load_if_ruby', 'db:structure:load_if_sql', :seed]

  desc 'Load the seed data from db/seeds.rb'
  task :seed do
    db_namespace['abort_if_pending_migrations'].invoke
    #Rails.application.load_seed
  end

  namespace :schema do
    desc 'Create a db/schema.rb file that can be portably used against any DB supported by AR'
    task :dump => [:environment, :load_config] do
      require 'active_record/schema_dumper'
      filename = ENV['SCHEMA'] || "#{Rails.root}/db/schema.rb"
      File.open(filename, "w:utf-8") do |file|
        ActiveRecord::Base.establish_connection(Rails.env)
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
      db_namespace['schema:dump'].reenable
    end

    desc 'Load a schema.rb file into the database'
    task :load => :environment do
      file = ENV['SCHEMA'] || "#{Rails.root}/db/schema.rb"
      if File.exists?(file)
        load(file)
      else
        abort %{#{file} doesn't exist yet. Run `rake db:migrate` to create it then try again. If you do not intend to use a database, you should instead alter #{Rails.root}/config/application.rb to limit the frameworks that will be loaded}
      end
    end

    task :load_if_ruby => 'db:create' do
      db_namespace["schema:load"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end

  namespace :structure do
    desc 'Dump the database structure to db/structure.sql. Specify another file with DB_STRUCTURE=db/my_structure.sql'
    task :dump => :environment do
      abcs = ActiveRecord::Base.configurations
      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, "db", "structure.sql")
      case abcs[Rails.env]['adapter']
      when /mysql/, 'oci', 'oracle'
        ActiveRecord::Base.establish_connection(abcs[Rails.env])
        File.open(filename, "w:utf-8") { |f| f << ActiveRecord::Base.connection.structure_dump }
      when /postgresql/
        set_psql_env(abcs[Rails.env])
        search_path = abcs[Rails.env]['schema_search_path']
        unless search_path.blank?
          search_path = search_path.split(",").map{|search_path_part| "--schema=#{search_path_part.strip}" }.join(" ")
        end
        `pg_dump -i -s -x -O -f #{filename} #{search_path} #{abcs[Rails.env]['database']}`
        raise 'Error dumping database' if $?.exitstatus == 1
      when /sqlite/
        dbfile = abcs[Rails.env]['database']
        `sqlite3 #{dbfile} .schema > #{filename}`
      when 'sqlserver'
        `smoscript -s #{abcs[Rails.env]['host']} -d #{abcs[Rails.env]['database']} -u #{abcs[Rails.env]['username']} -p #{abcs[Rails.env]['password']} -f #{filename} -A -U`
      when "firebird"
        set_firebird_env(abcs[Rails.env])
        db_string = firebird_db_string(abcs[Rails.env])
        sh "isql -a #{db_string} > #{filename}"
      else
        raise "Task not supported by '#{abcs[Rails.env]["adapter"]}'"
      end

      if ActiveRecord::Base.connection.supports_migrations?
        File.open(filename, "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
      end
    end

    # desc "Recreate the databases from the structure.sql file"
    task :load => [:environment, :load_config] do
      env = ENV['RAILS_ENV'] || 'test'

      abcs = ActiveRecord::Base.configurations
      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, "db", "structure.sql")
      case abcs[env]['adapter']
      when /mysql/
        ActiveRecord::Base.establish_connection(abcs[env])
        ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0')
        IO.read(filename).split("\n\n").each do |table|
          ActiveRecord::Base.connection.execute(table)
        end
      when /postgresql/
        set_psql_env(abcs[env])
        `psql -f "#{filename}" #{abcs[env]['database']}`
      when /sqlite/
        dbfile = abcs[env]['database']
        `sqlite3 #{dbfile} < "#{filename}"`
      when 'sqlserver'
        `sqlcmd -S #{abcs[env]['host']} -d #{abcs[env]['database']} -U #{abcs[env]['username']} -P #{abcs[env]['password']} -i #{filename}`
      when 'oci', 'oracle'
        ActiveRecord::Base.establish_connection(abcs[env])
        IO.read(filename).split(";\n\n").each do |ddl|
          ActiveRecord::Base.connection.execute(ddl)
        end
      when 'firebird'
        set_firebird_env(abcs[env])
        db_string = firebird_db_string(abcs[env])
        sh "isql -i #{filename} #{db_string}"
      else
        raise "Task not supported by '#{abcs[env]['adapter']}'"
      end
    end

    task :load_if_sql => 'db:create' do
      db_namespace["structure:load"].invoke if ActiveRecord::Base.schema_format == :sql
    end
  end
end

def drop_database(config)
  case config['adapter']
  when /mysql/
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection.drop_database config['database']
  when /sqlite/
    require 'pathname'
    path = Pathname.new(config['database'])
    file = path.absolute? ? path.to_s : File.join(Rails.root, path)

    FileUtils.rm(file)
  when /postgresql/
    ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.drop_database config['database']
  end
end

def drop_database_and_rescue(config)
  begin
    drop_database(config)
  rescue Exception => e
    $stderr.puts "Couldn't drop #{config['database']} : #{e.inspect}"
  end
end

def configs_for_environment
  Rails.configs_for_environment
end
=end