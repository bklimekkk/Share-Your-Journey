//
//  NoDataView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/07/2022.
//

import SwiftUI

struct NoDataView: View {
    @Environment(\.colorScheme) var colorScheme
    var text: String
    init() {
        self.text = UIStrings.emptyString
    }
    init(text: String) {
        self.text = text
    }
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text(self.text)
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
        }
        .background {
            self.colorScheme == .light ? Color.white : Color.black
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView()
    }
}
