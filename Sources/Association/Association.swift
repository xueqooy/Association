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

// By default, no wrapping is used, which corresponds to `none`.
private let objectAssociation = Association<CustomObject>()

// Use `weak` wrapping for weakly referenced associative objects.
private let weakObjectAssociation = Association<CustomObject>(wrap: .weak)

// It is recommended to use `direct` wrapping for custom value types.
// For types that can be bridged to Objective-C (e.g., String, Bool, Int), wrapping may not be necessary.
// Since Swift 3, custom value types are converted to `SwiftValue` in Objective-C, so wrapping may not be required.
private let structAssociation = Association<CustomStruct>(wrap: .direct)

// Closures should be associated using `direct` wrapping.
private let blockAssociation = Association<Block>(wrap: .direct)

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
