# Association

`Association` is a Swift library designed to dynamically associate values with objects at runtime. It provides various association policies and wrapping options, supporting both strong and weak references.

## Introduction

The `Association` class encapsulates the use of Objective-C runtime's associated objects feature, allowing dynamic property addition to objects. It supports the following association policies:

- `assign`
- `retainNonatomic`
- `copyNonatomic`
- `retain`
- `copy`

Additionally, the `Association` class supports wrapping:
- `direct`
- `weak`

## Example

 ```swift
struct CustomStruct {}
class CustomObject {}
typealias Block = () -> Void

extension UIView {
    private struct Associations {
        // The default is not to use wrap, that is, wrap to `none`
        static let objectAssociation = Association<CustomObject>()
 
        // Using `weak` wrap for weakly referenced associative object
        static let weakObjectAssociation = Association<CustomObject>(wrap: .weak)
 
        // It is recommended to use `direct` wrap for custom value types. For types that can be bridged to objc, such as String, Bool, Int, etc., Wrap may not be used
        // However, after Swift3, the custom value type will be converted to `SwiftValue` in objc, and Wrap may not be used.
        static let structAssociation = Association<CustomStruct>(wrap: .direct)
                
        // Associate closures must use `direct` wrap
        static let blockAssociation = Association<Block>(wrap: .direct)
    }

    var customStruct: CustomStruct? {
        get { Associations.structAssociation[self] }
        set { Associations.structAssociation[self] = newValue }
    }

    var customObject: CustomObject? {
        get { Associations.objectAssociation[self] }
        set { Associations.objectAssociation[self] = newValue }
    }

    var weakCustomObject: CustomObject? {
        get { Associations.weakObjectAssociation[self] }
        set { Associations.weakObjectAssociation[self] = newValue }
    }

    var block: Block? {
        get { Associations.blockAssociation[self] }
        set { Associations.blockAssociation[self] = newValue }
    }
}
```

## Installation

**Using [Swift Package Manager](https://swift.org/package-manager)**:

```swift
import PackageDescription

let package = Package(
  name: "MyAwesomeApp",
  dependencies: [
    .Package(url: "https://github.com/xueqooy/Association", majorVersion: 1),
  ]
)
```

## License

**Association** is under MIT license. See the [LICENSE](LICENSE) file for more info.
