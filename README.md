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

## Usage Example

Here's how you can use the Association class in your Swift project:

### Extend UIView with an Associated Property
```swift
import UIKit
import Association

class CustomObject {}

extension UIView {
    private enum Associations {
        static let objectAssociation = Association<CustomObject>()
    }

    var customObject: CustomObject? {
        get { Associations.objectAssociation[self] }
        set { Associations.objectAssociation[self] = newValue }
    }
}
```

### Comparison with Traditional Methods

```swift
import UIKit
import ObjectiveC.runtime

extension UIView {
    private enum Associations {
        static var customObjectKey = "customObjectKey"
    }

    var customObject: CustomObject? {
        get { objc_getAssociatedObject(self, &Associations.customObjectKey) as? CustomObject }
        set {
            objc_setAssociatedObject(self, &Associations.customObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
```

### And more

```swift
struct CustomStruct {}
class CustomObject {}
typealias Block = () -> Void

extension UIView {
    private struct Associations {
        // By default, no wrapping is used, which corresponds to `none`.
        static let objectAssociation = Association<CustomObject>()

        // Use `weak` wrapping for weakly referenced associative objects.
        static let weakObjectAssociation = Association<CustomObject>(wrap: .weak)

        // It is recommended to use `direct` wrapping for custom value types.
        // For types that can be bridged to Objective-C (e.g., String, Bool, Int), wrapping may not be necessary.
        // Since Swift 3, custom value types are converted to `SwiftValue` in Objective-C, so wrapping may not be required.
        static let structAssociation = Association<CustomStruct>(wrap: .direct)
    
        // Closures must be associated using `direct` wrapping.
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
