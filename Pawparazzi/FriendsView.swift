//
//  FriendsView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//
import SwiftUI
struct FriendsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Friends")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}
