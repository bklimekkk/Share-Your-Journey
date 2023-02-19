//
//  ChangeNicknameView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 29/01/2023.
//

import SwiftUI

struct ChangeNicknameView: View {
    @Environment(\.dismiss) var dismiss
    var oldNickname: String
    @State private var newNickname = ""
    @State private var showNicknameExistsAlert = false
    @State private var emptyField = false
    @State private var yourNickname = false

    var trimmedNewNickname: String {
        self.newNickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var body: some View {
        NavigationView {
        VStack {
            TextField(UIStrings.newNickname, text: self.$newNickname)
                .padding(.vertical, 5)
            Spacer()
            Button {
                if self.newNickname.isEmpty {
                    self.emptyField = true
                } else if self.newNickname == self.oldNickname {
                    self.yourNickname = true
                } else {
                    AccountManager.checkNicknameUniqueness(nickname: self.trimmedNewNickname) { unique in
                        if unique {
                            AccountManager.changeNickname(newNickname: self.trimmedNewNickname) {
                                self.dismiss()
                            }
                        } else {
                            self.showNicknameExistsAlert = true
                        }
                    }
                }
            } label: {
                ButtonView(buttonTitle: UIStrings.changeNicknameButtonTitle)
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .padding()
        .alert(Text(UIStrings.nicknameIsTaken), isPresented: self.$showNicknameExistsAlert){}
        .alert(Text(UIStrings.emptyField), isPresented: self.$emptyField) {}
        .alert(Text(UIStrings.currentNickname), isPresented: self.$yourNickname) {}
    }
    }
}
