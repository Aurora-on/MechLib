import Lean

namespace MechLib
namespace Spec

open Lean

/-- Declaration status used by MechLib metadata and retrieval gating. -/
inductive DeclStatus where
  | verified
  | schema
  | alias
  | experimental
  | todo
deriving DecidableEq, Repr

/-- Trust tier used to separate proof-safe declarations from interfaces and examples. -/
inductive TrustLevel where
  | core
  | derived
  | interface
  | example
deriving DecidableEq, Repr

def DeclStatus.toString : DeclStatus → String
  | .verified => "verified"
  | .schema => "schema"
  | .alias => "alias"
  | .experimental => "experimental"
  | .todo => "todo"

def TrustLevel.toString : TrustLevel → String
  | .core => "core"
  | .derived => "derived"
  | .interface => "interface"
  | .example => "example"

def stringListJson (xs : List String) : Json :=
  Json.arr (xs.map Json.str).toArray

def optionStringJson : Option String → Json
  | some value => Json.str value
  | none => Json.null

end Spec
end MechLib
