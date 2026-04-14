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

Person(<alias>, "<Name>", "<Description>")

System_Boundary(<alias>, "<System Name>") {

  Container(<alias>, "<Name>", "<Technology>", "<Description>")

  System_Boundary(<alias>, "<Sub-boundary Name>") {
    Container(<alias>, "<Name>", "<Technology>", "<Description>")
    ContainerDb(<alias>, "<Name>", "<Technology>", "<Description>")
  }
}

System_Boundary(external, "External Systems") {
  Container(<alias>, "<Name>", "<Technology>", "<Description>")
}

' Relationships
Rel(<from>, <to>, "<Description>")

@enduml
```

Rules:
- Use `Container` for services, apps, consumers, and message brokers
- Use `ContainerDb` for databases and object stores
- Use `System_Boundary` for logical groupings (layers, pipeline stages, external systems)
- Use `Person` for human actors
- Keep descriptions concise — one short sentence
- Include technology (e.g. `Java`, `Kafka`, `PostgreSQL`, `MinIO`) where known
- Add a `' Relationships` section at the end grouping all `Rel()` calls

### Step 3 — Render to PNG

Run:

```bash
bash scripts/plantuml-gen.sh <target-puml-path>
```

Report the output path of the generated PNG.
