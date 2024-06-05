# RDS DB Parameter Group Exporter

Export DB config files from an AWS RDS DB Parameter Group.

## Exported Parameters

Exported parameters are;
* Ones NOT engine defaults; the ones modified by users or by RDS default RDS DB parameter groups
* And ones which have some value

## Exported File

### Filepath

Files will be exported in `outputs/` directory.

The default basename of an exported file is `<rds-db-parameter-group-name>.<timestamp>`.
You can overwrite this basename with [config.yaml](#configyaml).

The extension will be automatically selected with RDS DB parameter group family;
* MySQL (`mysql5.5`, `mysql5.6`, `mysql5.7`, `mysql8.0`): `.cnf`

The full default filepath will be:

```
outputs/<rds-db-parameter-group-name>.<timestamp><extension>
```

### File format

The format of the configuration file will be automatically selected with RDS DB parameter group family;
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

```yaml
target:
  region: ap-northeast-1
  db_parameter_group_name: some_db_parameter_group_name

export:
  # basename: some_db_parameter_group_name # Optional
```

* `target`

  * `region`: Specify an AWS region (cf. `ap-northeast-1`).

  * `db_parameter_group_name`: Specify a name of RDS DB parameter group.

* `export`

  * `basename`:
    (Optional) When specified, the exported file's basename is overwritten by it:
    ```
    <specified-basename><extension>
    ```
    The extension (cf. `.cnf`) will be defined automatically with the RDS DB parameter group family
    of the RDS DB parameter group specified for `target.db_parameter_group_name` of
    this [config.yaml](#configyaml).
