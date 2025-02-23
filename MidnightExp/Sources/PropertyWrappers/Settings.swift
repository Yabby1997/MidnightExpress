//
//  Settings.swift
//  MidnightExp
//
//  Created by Seunghun on 2/23/25.
//  Copyright © 2025 seunghun. All rights reserved.
//

import Combine
import Foundation

@propertyWrapper
class Settings<Value: Codable>: NSObject {
    private weak var objectWillChange: ObservableObjectPublisher?
    private let key: String
    private let defaultValue: Value
    private let subject: CurrentValueSubject<Value?, Never>
    var projectedValue: AnyPublisher<Value, Never>

    @available(*, unavailable, message: "@Settings is only available on properties of classes")
    var wrappedValue: Value {
        get { fatalError("@Settings is only available on properties of classes") }
        set { fatalError("@Settings is only available on properties of classes") }
    }
    
    private var internalValue: Value {
        get { (try? JSONDecoder().decode(Value.self, from: UserDefaults.standard.data(forKey: key) ?? Data())) ?? defaultValue }
        set { UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: key) }
    }
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self.subject = CurrentValueSubject<Value?, Never>(nil)
        self.projectedValue = subject.compactMap { $0 }.eraseToAnyPublisher()
        super.init()
        objectWillChange?.send()
        subject.send(internalValue)
        UserDefaults.standard.addObserver(self, forKeyPath: key, options: [.new, .prior], context: nil)
    }
    
    deinit { UserDefaults.standard.removeObserver(self, forKeyPath: key) }
    
    static subscript<Enclosing: ObservableObject> (
        _enclosingInstance instance: Enclosing,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Enclosing, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Enclosing, Settings<Value>>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].objectWillChange = instance.objectWillChange as? ObservableObjectPublisher
            return instance[keyPath: storageKeyPath].internalValue
        }
        set {
            instance[keyPath: storageKeyPath].objectWillChange = instance.objectWillChange as? ObservableObjectPublisher
            instance[keyPath: storageKeyPath].internalValue = newValue
        }
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == key, (change?[.notificationIsPriorKey] as? Bool) == true else { return }
        objectWillChange?.send()
        subject.send(internalValue)
    }
}
