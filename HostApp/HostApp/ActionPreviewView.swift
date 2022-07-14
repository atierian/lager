//
//  File.swift
//  
//
//  Created by Ian Saultz on 7/13/22.
//

import SwiftUI

struct ActionPreviewView: View {
    let actions: [Model]
    
    var body: some View {
        ForEach(actions) { model in
            Button(action: model.action) {
                Text(model.label)
            }
                .buttonStyle(.bordered)
                .cornerRadius(8)
        }
    }
}

extension ActionPreviewView {
    struct Model: Identifiable {
        let id = UUID()
        let label: String
        let action: () -> Void
    }
}
