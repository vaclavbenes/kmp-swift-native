import Foundation

@objc public class HelloFromLocalPackage: NSObject {
    @objc public func hello() {
        print("Hello from Swift LocalPackage!")
    }

    @objc public func greet(name: String) -> String {
        return "Hello, \(name), from Swift LocalPackage!"
    }

    @objc public func calculateSum(a: Int, b: Int) -> Int {
        return a + b
    }
}
