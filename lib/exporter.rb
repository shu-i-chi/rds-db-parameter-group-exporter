require "time"

class Exporter
  class NotCompatibleDBParameterGroupFamilyError < StandardError
  end

  module DBEngine
    MYSQL = "MySQL"
  end

  EXPORT_DIR = "outputs"

  private attr_reader :db_parameter_group_name, :db_parameter_group_family, :region,
                      :system_modified_db_parameters, :user_modified_db_parameters,
                      :db_engine

  def initialize(db_parameter_group_name:, db_parameter_group_family:, region:,
                 system_modified_db_parameters:, user_modified_db_parameters:)
    db_engine = case db_parameter_group_family
                when "mysql5.5", "mysql5.6", "mysql5.7", "mysql8.0"
                  DBEngine::MYSQL
                else
                  raise NotCompatibleDBParameterGroupFamilyError,
                        "DB parameter group family '#{db_parameter_group_family}'" +
                        " is not compatible for this export program."
                end

    @db_engine = db_engine

    @db_parameter_group_name = db_parameter_group_name
    @db_parameter_group_family = db_parameter_group_family
    @region = region

    @system_modified_db_parameters = system_modified_db_parameters
    @user_modified_db_parameters = user_modified_db_parameters
  end

  def export(basename = nil)
    now = Time.now.localtime("+09:00")

    if basename
      filepath = "#{EXPORT_DIR}/#{basename}#{self.extname}"
    else
      filepath = self.default_filepath(time: now)
    end

    File.open(filepath, "w") do |file|
      output_header_comment(file: file, time: now)

      case self.db_engine
      when DBEngine::MYSQL
        file.puts "[mysqld]"
        file.puts ""

        # The parameters which specified by default DB parameter group
        output_parameters_as_ini(
          file: file,
          comment: "The parameters which specified by default DB parameter group " +
          "(Source: System default)",
          db_parameters: self.system_modified_db_parameters
        )

        # The parameters which specified by users
        output_parameters_as_ini(
          file: file,
          comment: "The parameters which specified by users (Source: Modified)",
          db_parameters: self.user_modified_db_parameters
        )
      end
    end

    filepath
  end

  private

  def extname
    @extname ||= case self.db_engine
                      when DBEngine::MYSQL
                        ".cnf"
                      end
  end

  def default_filepath(time:)
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    basename = "#{db_parameter_group_name}.#{timestamp}"

    "#{EXPORT_DIR}/#{basename}#{self.extname}"
  end

  def output_header_comment(file:, time:)
    timestamp = time.iso8601

    file.puts "# #{self.db_engine} config file exported from AWS RDS DB parameter group:"
    file.puts "#   * DB parameter group name: #{self.db_parameter_group_name}"
    file.puts "#   * DB parameter group family: #{self.db_parameter_group_family}"
    file.puts "#   * region: #{self.region}"
    file.puts "# (Exported at: #{timestamp})"
    file.puts ""
  end

  def output_parameters_as_ini(file:, comment:, db_parameters:)
    file.puts "#"
    file.puts "# #{comment}"
    file.puts "#"
    file.puts ""

    db_parameters.each do |db_parameter|
      file.puts "# #{db_parameter.description}"
      file.puts "#{db_parameter.parameter_name} = #{db_parameter.parameter_value}"
      file.puts ""
    end
  end
end
