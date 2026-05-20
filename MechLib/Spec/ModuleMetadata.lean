import MechLib.Spec.Status

namespace MechLib
namespace Spec

open Lean

/-- Module-level status for course-layer wrapper/interface modules.

This is intentionally separate from `DeclStatus`: module skeletons may be
`interface` even when no theorem declaration has that status. -/
inductive ModuleStatus where
  | verified
  | schema
  | interface
  | experimental
  | todo
deriving DecidableEq, Repr

def ModuleStatus.toString : ModuleStatus → String
  | .verified => "verified"
  | .schema => "schema"
  | .interface => "interface"
  | .experimental => "experimental"
  | .todo => "todo"

/-- Metadata exported for each course-layer module. -/
structure ModuleMetadata where
  modulePath : String
  topicId : String
  status : ModuleStatus
  trustLevel : TrustLevel
  conceptIds : List String
  lawSchemaIds : List String
  problemSchemaIds : List String
  exampleProblems : List String
  notes : List String
deriving Repr

namespace ModuleMetadata

def toJson (m : ModuleMetadata) : Json :=
  Json.mkObj [
    ("module_path", Json.str m.modulePath),
    ("topic_id", Json.str m.topicId),
    ("status", Json.str m.status.toString),
    ("trust_level", Json.str m.trustLevel.toString),
    ("concept_ids", stringListJson m.conceptIds),
    ("law_schema_ids", stringListJson m.lawSchemaIds),
    ("problem_schema_ids", stringListJson m.problemSchemaIds),
    ("example_problems", stringListJson m.exampleProblems),
    ("notes", stringListJson m.notes)
  ]

end ModuleMetadata

end Spec
end MechLib
