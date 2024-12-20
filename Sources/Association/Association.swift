/// The MIT License (MIT)
//
// Copyright (c) 2024 xueqooy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import ObjectiveC.runtime

/**
 ```
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
*/

public class Association<T> {
    
    public enum Policy {
        case assign
        case retainNonatomic
        case copyNonatomic
        case retain
        case copy
    }
    
    public enum Wrap {
        case direct
        case weak // Only used for class type
    }
    
    private let associationPolicy: objc_AssociationPolicy
    private let wrap: Wrap?
    
    public init(policy: Policy = .retainNonatomic, wrap: Wrap? = .none) {
        switch policy {
        case .assign:
            associationPolicy = .OBJC_ASSOCIATION_ASSIGN
        case .retainNonatomic:
            associationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .copyNonatomic:
            associationPolicy = .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .retain:
            associationPolicy = .OBJC_ASSOCIATION_RETAIN
        case .copy:
            associationPolicy = .OBJC_ASSOCIATION_COPY
        }
        
        self.wrap = wrap
    }
    
    public subscript(index: AnyObject) -> T? {
        get {
            switch wrap {
            case .none:
                return objc_getAssociatedObject(index, key) as? T
            case .direct:
                return (objc_getAssociatedObject(index, key) as? Box<T>)?.value
            case .weak:
                return (objc_getAssociatedObject(index, key) as? WeakBox<T>)?.value
            }
        }
        set {
            if let value = newValue {
                switch wrap {
                case .none:
                    objc_setAssociatedObject(index, key, value, associationPolicy)
                case .direct:
                    objc_setAssociatedObject(index, key, Box(value), associationPolicy)
                case .weak:
                    objc_setAssociatedObject(index, key, WeakBox(value), associationPolicy)
                }
            } else {
                objc_setAssociatedObject(index, key, nil, associationPolicy)
            }
        }
    }
    
    private var key: UnsafeRawPointer {
        UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
}

private class WeakBox<T> {
    var value: T? {
        _value as? T
    }

    private weak var _value: AnyObject?
    
    init(_ value: T) {
        self._value = value as AnyObject
    }
}

private class Box<T> {
    let value: T

    init(_ value: T) {
        self.value = value
    }
}
