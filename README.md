# RDS DB Parameter Group Exporter

Export DB config files from an AWS RDS DB Parameter Group.

The parameters which are NOT engine defaults; the ones modified by users or RDS default DB Parameter Group.

# Prerequisites

* AWS IAM

# Usage

The default filepath exported is: `outputs/<rds-db-parameter-group-name>.<timestamp>.<ext>`

1. Git clone this repository:

   ```bash
   git clone https://github.com/shu-i-chi/rds-db-parameter-group-exporter.git
   ```

2. Move to the directory for this repository

   ```bash
   cd ./rds-db-parameter-group-exporter
   ```

2. Edit config.yaml:

   ```bash
   vim config.yaml
   ```

3. Then execute the program:

   ```bash
   bundle install
   bundle exec ruby export_rds_db_parameter_group.rb
   ```

   If succeeds, you can see an output line like;
   
   ```bash
   Successfully exported 'outputs/<rds-db-parameter-group-name>.<timestamp>.cnf'. # for MySQL
   ```

# config.yaml

