class Config
  attr_reader :region, :db_parameter_group_name, :exported_file_basename

  CONFIG_FILE = "config.yaml"

  include Singleton

  def initialize
    config = YAML.load_file(CONFIG_FILE) # Hash

    @region = config["target"]["region"]
    @db_parameter_group_name = config["target"]["db_parameter_group_name"]

    @exported_file_basename = config.dig("export", "basename")
  end
end
