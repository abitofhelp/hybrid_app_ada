# Input Ports (Inward/Driving Ports)

## Overview

Input ports are the **entry points INTO the application core** from the outside world (presentation layer). In hexagonal architecture, these are also called "driving ports" because external actors (CLI, HTTP handlers, etc.) **drive** the application by calling these ports.

## Architectural Pattern Comparison: Go vs Ada

### Go Implementation (Interface-Based)

In the Go version of this application, each input port is defined as a **separate interface file**:

```go
// application/port/inward/greet_port.go
type GreetPort interface {
    Execute(ctx context.Context, cmd command.GreetCommand) mo.Result[model.Unit]
}
```

**If you add 10 more use cases, you create 10 more interface files:**
- `greet_port.go`
- `update_user_port.go`
- `delete_order_port.go`
- `create_invoice_port.go`
- etc.

Each interface explicitly documents the contract between presentation and application layers.

### Ada Implementation (Generic-Based)

In this Ada version, input ports are defined **inline as generic formal function parameters** in the presentation layer components:

```ada
-- presentation/cli/command/greet.ads
generic
   with function Execute_Greet_UseCase
     (Cmd : Application.Command.Greet.Greet_Command)
      return Application.Port.Outward.Writer.Unit_Result.Result;
package Presentation.CLI.Command.Greet is
   -- ...
end Presentation.CLI.Command.Greet;
```

**If you add 10 more use cases, you create 10 more generic formal parameters** in their respective presentation components. No separate input port interface files are needed.

## Why the Difference?

### Language Idioms

- **Go**: Interfaces are the idiomatic way to define contracts. They're explicit, well-understood, and provide clear documentation of dependencies.
- **Ada**: Generics are the idiomatic way to achieve dependency inversion with static dispatch. The generic formal parameter signature **IS** the contract.

### Architectural Equivalence

Both approaches achieve the **same architectural goals**:

1. ✅ **Dependency Inversion**: Presentation depends on application abstractions, not implementations
2. ✅ **Testability**: Presentation can be tested with mock implementations
3. ✅ **Clear Contracts**: The interface/generic signature defines what the presentation layer needs
4. ✅ **Static Dispatch**: Both use compile-time binding (Go with generics, Ada with generic instantiation)

### Trade-offs

| Aspect | Go (Interface Files) | Ada (Generic Parameters) |
|--------|---------------------|-------------------------|
| **Explicitness** | Very explicit - separate file per port | Implicit - contract embedded in generic |
| **Discoverability** | Easy - just look in `port/inward/` directory | Requires reading presentation layer |
| **Boilerplate** | More files to maintain | Less boilerplate |
| **Documentation** | Port files serve as documentation | Need comments in presentation layer |
| **Architectural Clarity** | Port files make hexagon boundaries obvious | Boundaries are conceptual, not file-based |

## Why This Directory Exists (But Is Empty)

This `application/port/inward/` directory exists in the Ada project to:

1. **Mirror the Go project structure** for educational comparison
2. **Document the architectural concept** of input ports
3. **Provide a place for this explanation** (this README.md)

In a pure Ada project without educational constraints, this directory might not exist at all, since input ports are defined inline as generic parameters.

## Adding New Input Ports

### In Go:
1. Create `application/port/inward/new_port.go`
2. Define the interface with the required method(s)
3. Have use case implement the interface
4. Have presentation depend on the interface

### In Ada:
1. Create the presentation component (e.g., `Presentation.CLI.Command.NewCommand`)
2. Add a `generic` clause with the required function signature
3. Have bootstrap instantiate with the concrete use case function
4. No separate port file needed

## Example: Adding a "DeleteUser" Use Case

### Go Approach:
```go
// application/port/inward/delete_user_port.go
package inward

type DeleteUserPort interface {
    Execute(ctx context.Context, userID string) mo.Result[model.Unit]
}
```

### Ada Approach:
```ada
-- presentation/cli/command/delete_user.ads
generic
   with function Execute_DeleteUser_UseCase
     (User_ID : String)
      return Application.Port.Outward.Writer.Unit_Result.Result;
package Presentation.CLI.Command.Delete_User is
   function Run return Integer;
end Presentation.CLI.Command.Delete_User;
```

## Key Takeaway

**Go uses explicit interface files because that's idiomatic Go.**

**Ada uses generic formal parameters because that's idiomatic Ada.**

Both achieve the same hexagonal architecture pattern with dependency inversion and static dispatch. The difference is in **how the contract is expressed**, not in the architectural principles being followed.

## References

- See `presentation/cli/command/greet.ads` for the Ada input port pattern in action
- See Go project's `application/port/inward/greet_port.go` for the Go input port pattern
- See `bootstrap/cli/bootstrap-cli.adb` for how input ports are wired at the composition root
