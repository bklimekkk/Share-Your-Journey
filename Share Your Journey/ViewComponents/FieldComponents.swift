//
//  FieldComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import SwiftUI

//Struct used for generating keyboard of email type.
struct EmailTextField: View {
    var label: String
    var email: Binding<String>
    var body: some View {
        TextField(self.label, text: self.email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding(.vertical, 10)
            .font(.system(size: 20))
    }
}

//Struct contains code that generates field used for searching lists in the application.
struct SearchField: View {
    var text: String
    @Binding var search: String
    var body: some View {
        VStack {
            TextField(self.text, text: self.$search)
                .padding(.horizontal)
            Divider()
        }
    }
}
