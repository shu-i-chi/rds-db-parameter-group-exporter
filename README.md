# RDS DB Parameter Group Exporter

Export DB config files from an AWS RDS DB Parameter Group.

## Exported Parameters

Exported parameters are;
* Ones NOT engine defaults; the ones modified by users or by RDS default DB Parameter Groups
* And ones which have some value

## Exported File

### Filepath

Files will be exported in `outputs/` directory.

The default basename of an exported file is `<rds-db-parameter-group-name>.<timestamp>`.
This basename can be set with [config.yaml](#configyaml).

The extension will be automatically selected with DB Parameter group family;
* MySQL (`mysql5.5`, `mysql5.6`, `mysql5.7`, `mysql8.0`): `.cnf`

The full default filepath will be:

```
outputs/<rds-db-parameter-group-name>.<timestamp><extension>
```

### File format

The format of the configuration file will be automatically selected with DB Parameter group family;
* MySQL (`mysql5.5`, `mysql5.6`, `mysql5.7`, `mysql8.0`): `ini` format with `#` comment

# Prerequisites

* AWS IAM

# Usage

The default filepath exported is: `outputs/<rds-db-parameter-group-name>.<timestamp>.<ext>`

1. Git clone this repository:

   ```bash
   git clone https://github.com/shu-i-chi/rds-db-parameter-group-exporter.git
   ```

2. Move to the directory for this repository:

   ```bash
   cd ./rds-db-parameter-group-exporter
   ```

2. Edit config.yaml:

   ```bash
   vim config.yaml
   ```

   See [config.yaml](#configyaml).

3. Bundle install:

   ```bash
   bundle install
   ```

4. Execute the program:

   ```bash
   bundle exec ruby export_rds_db_parameter_group.rb
   ```

   If succeeds, you can see an output line like;
   
   ```bash
   Successfully exported:

     outputs/<rds-db-parameter-group-name>.<timestamp>.cnf
   ```

# config.yaml

