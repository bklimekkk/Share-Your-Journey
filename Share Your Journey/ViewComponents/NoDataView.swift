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
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.00))
            VStack {
                Spacer()
                Text(text)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView(text: "")
    }
}
