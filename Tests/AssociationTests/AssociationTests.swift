import Testing
@testable import Association

class MyObject {
}

struct MyStruct: Equatable {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class MyGenericObject<T> {
    let value: T
    init(value: T) {
        self.value = value
    }
}

@Test func testStruct() async throws {
    let association = Association<MyStruct>(wrap: .direct)

    let object = MyObject()
    let struct1 = MyStruct(name: "Struct 1")
    association[object] = struct1
    
    #expect(association[object] == struct1, "value should be equal to struct1")
    
}

@Test func testObject() async throws {
    let association = Association<MyObject>()

    let object = MyObject()
    let object1 = MyObject()
    association[object] = object1
    
    #expect(association[object] === object1, "value should be object1")
}

@Test func testWeakObject() async throws {
    let association = Association<MyObject>(wrap: .weak)

    let object = MyObject()
    var object1: MyObject? = MyObject()
    association[object] = object1
    
    #expect(association[object] === object1, "value should be object1")
    
    object1 = nil
    #expect(association[object] == nil, "objectValue should be nil")
}

@Test func testGenericObject() async throws {
    let association = Association<MyGenericObject<MyStruct>>()

    let object = MyObject()
    let object1 = MyGenericObject(value: MyStruct(name: "Generic"))
    association[object] = object1
    
    #expect(association[object] === object1, "value should be object1")
}

@Test func testBlock() async throws {
    let association = Association<() -> String>(wrap: .direct)
    
    let object = MyObject()
    var block: (() -> String)? = {
        "Hello"
    }
    association[object] = block
    block = nil
    
    #expect(association[object] != nil && association[object]!() == "Hello", "Block should return Hello")
}
