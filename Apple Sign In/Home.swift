//
//  Home.swift
//  Apple Sign In
//
//  Created by Md Khorshed Alam on 10/9/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Home: View {
    @AppStorage("log_status") private var logStatus: Bool = false

    var body: some View {
        NavigationStack {
            Button("LogOut") {
                try? Auth.auth().signOut()
                logStatus = false
            }
            .navigationTitle("Home")
        }
    }
}

//#Preview {
//    Home()
//}
