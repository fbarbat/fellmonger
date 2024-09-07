//
//  FellmongerApp.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 10/5/24.
//

import SwiftUI

import MacOSRoot

@main
@MainActor
struct FellmongerApp: App {
    @State private var rootSceneModel = RootSceneModel()

    var body: some Scene {
        RootScene(model: rootSceneModel)
    }
}
