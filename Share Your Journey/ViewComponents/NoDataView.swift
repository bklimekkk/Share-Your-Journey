//
//  NoDataView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/07/2022.
//

import SwiftUI

struct NoDataView: View {
    var text: String
    init() {
        self.text = ""
    }
    init(text: String) {
        self.text = text
    }
    var body: some View {
        VStack {
            Spacer()
            Text(self.text)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView()
    }
}
