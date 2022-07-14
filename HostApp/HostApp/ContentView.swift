//
//  ContentView.swift
//  HostApp
//
//  Created by Ian Saultz on 7/13/22.
//

import SwiftUI
import Lager

struct ContentView: View {
    
    var models: [ActionPreviewView.Model] = []
    
    init() {
        models = [
            .init(label: "Perist", action: persist),
            .init(label: "Query", action: query),
            .init(label: "Delete", action: delete)
        ]
    }
    
    func persist() {
        do {
            try Lager.Keychain.set(true, forKey: "io.coffee.boolean", withAccessibility: .afterFirstUnlock)
            print("Persisted!")
        } catch {
            print(error)
        }
    }
    
    func query() {
        do {
            let value = try Lager.Keychain.bool(forKey: "io.coffee.boolean", withAccessibility: .afterFirstUnlock)
            print("Queried with result: \(value)")
        } catch {
            print(error)
        }
    }
    
    func delete() {
        do {
            try Lager.Keychain.delete(key: "io.coffee.boolean", withAccessibility: .afterFirstUnlock)
            print("Deleted!")
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        ActionPreviewView(actions: models)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
