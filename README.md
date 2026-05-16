# KMP Swift Native

A Kotlin Multiplatform project demonstrating how Kotlin/Native can consume a local Swift package via SwiftPM integration. Includes a real-world example of accessing the macOS Keychain from Kotlin through a Swift wrapper.

## What this is

Kotlin/Native can call Swift code through an Objective-C bridge. This project wires up that bridge end-to-end: a Swift package exposes `@objc`-annotated classes, the Gradle build links them via `swiftPMDependencies`, and Kotlin imports them as regular types from the `swiftPMImport.kmp.swift.native.*` package.

## Project layout

| Path | Description |
|------|-------------|
| `src/nativeMain/kotlin/Main.kt` | Entry point |
| `src/nativeMain/kotlin/Library.kt` | JSON serialization with kotlinx-serialization |
| `src/nativeMain/kotlin/UseLocalPackage.kt` | Calls Swift functions (greetings, arithmetic) |
| `src/nativeMain/kotlin/Keychain.kt` | Lists macOS Keychain items via the Swift wrapper |
| `LocalPackage/Sources/LocalPackage/` | Swift target: basic API (`hello`, `greet`, `calculateSum`) |
| `LocalPackage/Sources/KeychainService/` | Swift target: full Keychain read/search wrapper |
| `build.gradle.kts` | Kotlin/Native build config with SwiftPM dependency |

## How it works

```
Swift (@objc class)
  → Objective-C bridge (compiler-generated header)
    → Kotlin/Native C interop
      → imported as swiftPMImport.kmp.swift.native.*
```

`build.gradle.kts` links the package with:

```kotlin
swiftPMDependencies {
    localPackage(path = "../LocalPackage")
}
```

Kotlin then calls Swift directly:

```kotlin
val pkg = HelloFromLocalPackage()
println(pkg.greet(name = "World"))
```

## Build & run

Requires macOS with Xcode and a JDK.

```bash
./gradlew runDebugExecutableNative
```

## Requirements

- macOS (Keychain features) or Linux/Windows (core interop only)
- Xcode / Swift toolchain
- JDK 11+
- Kotlin 2.x
