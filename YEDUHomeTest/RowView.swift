//
//  RowView.swift
//  YEDUHomeTest
//
//  Created by MACBOOK on 18/06/2022.
//

import SwiftUI

struct RowView: View {
    var model: RowViewModel
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.white
                .cornerRadius(15)
                .shadow(color: .black, radius: 5, x: 0, y: 2)
                .frame(height: 120)
            HStack(alignment: .center, spacing: 10) {
                AsyncImage(url: URL(string: model.picture))
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)
                    .padding()
                    .clipped()
                VStack(alignment: .leading, spacing: 20) {
                    Text(model.firstName)
                    Text(model.lastName)
                }
                Spacer()
            }
        }.padding()
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(model: sampleModel)
    }
}

struct RowViewModel: Codable, Hashable, Identifiable {
    var id: String
    var title: String
    var firstName: String
    var lastName: String
    var picture: String
}

let sampleModel = RowViewModel(id: "60d0fe4f5311236168a109ca", title: "ms", firstName: "Sara", lastName: "Andersen", picture: "https://randomuser.me/api/portraits/women/58.jpg")
