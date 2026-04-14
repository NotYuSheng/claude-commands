Generate or update a C4 Container diagram as a PlantUML file, then render it to PNG.

## Inputs

- `$ARGUMENTS` — output path for the `.puml` file (optional). If omitted, default to `docs/c4-container.puml`.

## Procedure

### Step 1 — Understand the system

Read the codebase to identify:
- **Users / personas** — who interacts with the system
- **System boundary** — the top-level system being described
- **Containers** — deployable units: services, databases, frontends, consumers, etc.
- **Sub-boundaries** — logical groupings within the system (e.g. pipeline stages, layers)
- **External systems** — third-party or out-of-scope systems the containers interact with
- **Relationships** — how containers communicate (protocol/technology where known)

### Step 2 — Write the `.puml` file

Write the C4 Container diagram to the target path using this template:

```plantuml
@startuml
!includeurl https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

LAYOUT_WITH_LEGEND()

title <System Name> — C4 Container Diagram v1.0.0

Person(user, "User", "Description of the user")

System_Boundary(system, "System Name") {

  Container(service_a, "Service A", "Technology", "Description")

  System_Boundary(sub_boundary, "Sub-boundary Name") {
    Container(service_b, "Service B", "Technology", "Description")
    Container(service_c, "Service C", "Technology", "Description")

    ContainerDb(db, "Database", "Technology", "Description")
  }
}

System_Boundary(external, "External Systems") {
  Container(ext_service, "External Service", "Technology", "Description")
}

' Relationships
Rel(user, service_a, "Description of interaction")
Rel(service_a, service_b, "Description of interaction")
Rel(service_b, db, "Description of interaction")
Rel(service_b, ext_service, "Description of interaction")

@enduml
```

Rules:
- Use `Container` for services, apps, consumers, and message brokers
- Use `ContainerDb` for databases and object stores
- Use `System_Boundary` for logical groupings (layers, pipeline stages, external systems)
- Use `Person` for human actors
- Keep descriptions concise — one short sentence
- Include technology (e.g. `Java`, `Kafka`, `PostgreSQL`, `MinIO`) where known
- Group all `Rel()` calls under a `' Relationships` comment at the end

### Step 3 — Render to PNG

Run:

```bash
bash scripts/plantuml-gen.sh <target-puml-path>
```

Report the output path of the generated PNG.
