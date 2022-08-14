//
//  NoDataView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/07/2022.
//

import SwiftUI

struct NoDataView: View {
    var text: String
    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView(text: "")
    }
}
