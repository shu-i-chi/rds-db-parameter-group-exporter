require "aws-sdk-rds"

require_relative "lib/config"
require_relative "lib/exporter"

# Load config.yaml
begin
  config = Config.instance
rescue => e
  puts "An error occured with loading file '#{Config::CONFIG_FILE}'."

  raise e
end

# Start
rds_client = Aws::RDS::Client.new(region: config.region)

puts "Start to export the RDS DB parameter group:"
puts ""
puts "  #{config.db_parameter_group_name} (#{config.region})"
puts ""

# Fetch all the DB parameters of the RDS DB parameter group
begin
  all_db_parameters = rds_client
                        .describe_db_parameters(
                          {:db_parameter_group_name => config.db_parameter_group_name}
                        )
                        .map { |response| response.parameters }
                        .flatten
rescue Aws::RDS::Errors::DBParameterGroupNotFound, Aws::RDS::Errors::InvalidParameterValue => e
  puts "There is no RDS DB parameter group '#{config.db_parameter_group_name}'" +
       " (region: #{config.region})."

  abort "Program aborted."
rescue => e
  puts "An error occured with fetching parameters" +
       " from RDS DB parameter group '#{config.db_parameter_group_name}'."

  raise e
end

# Select DB parameters for which some values specified.
system_modified_db_parameters = []
user_modified_db_parameters = []

all_db_parameters
  .reject { |db_parameter| db_parameter.parameter_value.nil? }
  .each do |db_parameter|
    case db_parameter.source
    when "system"
      system_modified_db_parameters << db_parameter
    when "user"
      user_modified_db_parameters << db_parameter
    end
  end

# Output
begin
  describe_db_parameter_groups_response = rds_client.describe_db_parameter_groups(
    {:db_parameter_group_name => config.db_parameter_group_name}
  )

  db_parameter_group_family = describe_db_parameter_groups_response.db_parameter_groups.first
                                .db_parameter_group_family

  exporter = Exporter.new(
    db_parameter_group_name: config.db_parameter_group_name,
    db_parameter_group_family: db_parameter_group_family,
    region: config.region,
    system_modified_db_parameters: system_modified_db_parameters,
    user_modified_db_parameters: user_modified_db_parameters
  )

  exported_filepath = if config.exported_file_basename
                        exporter.export(config.exported_file_basename)
                      else
                        exporter.export
                      end

  puts "Successfully exported:"
  puts ""
  puts "  #{exported_filepath}"
  puts ""
rescue Aws::RDS::Errors::DBParameterGroupNotFound, Aws::RDS::Errors::InvalidParameterValue => e
  puts "There is no RDS DB parameter group '#{config.db_parameter_group_name}'" +
       " (region: #{config.region})."

  abort "Program aborted."
rescue Exporter::NotCompatibleDBParameterGroupFamilyError => e
  puts e.message

  abort "Program aborted."
end
