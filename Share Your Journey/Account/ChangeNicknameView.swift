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
    @State private var newNickname = UIStrings.emptyString
    @State private var showNicknameExistsAlert = false
    @State private var emptyField = false
    @State private var yourNickname = false
    var body: some View {
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
                    AccountManager.checkNicknameUniqueness(nickname: self.newNickname) { unique in
                        if unique {
                            AccountManager.changeNickname(newNickname: self.newNickname) {
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
        .alert(isPresented: self.$showNicknameExistsAlert) {
            Alert(title: Text(UIStrings.nicknameIsTaken))
        }
        .alert(isPresented: self.$emptyField) {
            Alert(title: Text(UIStrings.emptyField))
        }
        .alert(isPresented: self.$yourNickname) {
            Alert(title: Text(UIStrings.currentNickname))
        }
    }
}
