//
//  NoDataView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/07/2022.
//

import SwiftUI

struct NoDataView: View {
    var text: String
    @State var time = 5
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    init() {
        self.text = UIStrings.emptyString
    }
    init(text: String) {
        self.text = text
    }
    var body: some View {
        VStack {
            Spacer()
            if time > 0 {
                ProgressView()
                    .onReceive(timer) { _ in
                        if time > 0 {
                            time -= 1
                        }
                    }
            } else {
                Text(self.text)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView()
    }
}
