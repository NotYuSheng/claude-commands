Generate or update an ERD diagram as a PlantUML file, then render it to PNG.

## Inputs

- `$ARGUMENTS` — output path for the `.puml` file (optional). If omitted, default to `docs/erd.puml`.

## Procedure

### Step 1 — Understand the schema

Read the codebase to identify:
- **Tables / entities** — from SQL schema files, ORM models, or migration files
- **Columns** — name, type, and whether primary key (`*`) or nullable
- **Foreign keys** — relationships between tables
- **Logical sections** — group related tables under named section comments
- **Source name** — for the footer (e.g. from `source.yml` or the schema file path)

### Step 2 — Write the `.puml` file

Write the ERD to the target path using this template:

```plantuml
@startuml ERD Template

footer Schema v1.0.0 | <source>/<filename>

skinparam linetype ortho
hide circle
hide methods
hide stereotypes

' ==========================
' SECTION NAME
' ==========================

entity "table_name" as table_name {
  * primary_key_id : serial
  --
  column_name : varchar(255)
  foreign_key_id : int
  flag_column : boolean
}

' ==========================
' ANOTHER SECTION
' ==========================

entity "another_table" as another_table {
  * primary_key_id : serial
  --
  column_name : varchar(100)
  numeric_col : int
  timestamp_col : timestamp
  date_col : date
}

entity "lookup_table" as lookup_table {
  * lookup_id : serial
  --
  lookup_name : varchar(50)
}

' ==========================
' JUNCTION / LINK TABLE
' ==========================

entity "join_table" as join_table {
  * table_a_id : int
  * table_b_id : int
  --
  created_at : timestamp
  created_by : int
}

' ==========================
' RELATIONSHIPS
' ==========================

' One-to-many
lookup_table    ||--o{ table_name      : "foreign_key_id"

' One-to-many
table_name      ||--o{ join_table      : "table_a_id"
another_table   ||--o{ join_table      : "table_b_id"

' One-to-one (optional)
table_name      ||--o| another_table   : "foreign_key_id"

@enduml
```

Rules:
- Mark primary key columns with `*`
- Separate PKs from other columns with `--`
- Group related tables under `' ==========================` section comments
- Use relationship notation: `||--o{` (one-to-many), `||--o|` (one-to-one optional), `}o--o{` (many-to-many via junction)
- Label each relationship with the foreign key column name
- Set the footer to `Schema v<version> | <source>/<schema-file>`

### Step 3 — Render to PNG

Run:

```bash
bash scripts/plantuml-gen.sh <target-puml-path>
```

Report the output path of the generated PNG.
