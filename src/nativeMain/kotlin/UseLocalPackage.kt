import swiftPMImport.kmp.swift.native.HelloFromLocalPackage

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
fun useLocalPackage() {
    val hello = HelloFromLocalPackage()

    // Call the hello() function
    hello.hello()

    // Call the greet function with a name
    val greeting = hello.greetWithName("Kotlin")
    println(greeting)

    // Call the calculateSum function
    val sum = hello.calculateSumWithA(42, b = 58)
    println("Sum: $sum")
}
