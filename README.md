# Association

`Association` is a Swift library designed to dynamically associate values with objects at runtime.

## At a Glance

Extend UIView with an object.
```swift
class CustomObject {}
```

```swift
import Association

private let objectAssociation = Association<CustomObject>()

extension UIView {
    var customObject: CustomObject? {
        get { Associations.objectAssociation[self] }
        set { Associations.objectAssociation[self] = newValue }
    }
}
```

comparison with Traditional Method:

```swift
import ObjectiveC.runtime

private var customObjectKey = "customObjectKey"

extension UIView {
    var customObject: CustomObject? {
        get {
            objc_getAssociatedObject(
                self,
                &Associations.customObjectKey
            ) as? CustomObject
        }
        set {
            objc_setAssociatedObject(
                self,
                &Associations.customObjectKey,
                newValue,
               .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
```

### Tips and Tricks

```swift
struct CustomStruct {}
class CustomObject {}
typealias Block = () -> Void

// By default, no wrapping is used, which corresponds to `none`.
private let objectAssociation = Association<CustomObject>()

// Use `weak` wrapping for weakly referenced associative objects.
private let weakObjectAssociation = Association<CustomObject>(wrap: .weak)

// It is recommended to use `direct` wrapping for custom value types.
// For types that can be bridged to Objective-C (e.g., String, Bool, Int), wrapping may not be necessary.
// Since Swift 3, custom value types are converted to `SwiftValue` in Objective-C, so wrapping may not be required.
static let structAssociation = Association<CustomStruct>(wrap: .direct)

// Closures must be associated using `direct` wrapping.
static let blockAssociation = Association<Block>(wrap: .direct)

extension UIView {
    var customStruct: CustomStruct? {
        get { structAssociation[self] }
        set { structAssociation[self] = newValue }
    }

    var customObject: CustomObject? {
        get { objectAssociation[self] }
        set { objectAssociation[self] = newValue }
    }

    var weakCustomObject: CustomObject? {
        get { weakObjectAssociation[self] }
        set { weakObjectAssociation[self] = newValue }
    }

    var block: Block? {
        get { blockAssociation[self] }
        set { blockAssociation[self] = newValue }
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
