//
//  SheetDismissButtonView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/12/2022.
//

import SwiftUI

struct SheetDismissButtonView: View {
    var body: some View {
        Image(systemName: "chevron.compact.down")
            .font(.system(size: 40))
    }
}

struct SheetDismissButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SheetDismissButtonView()
    }
}
