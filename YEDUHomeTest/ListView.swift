//
//  ContentView.swift
//  YEDUHomeTest
//
//  Created by MACBOOK on 17/06/2022.
//

import SwiftUI

struct ListView: View {
    @State private var searchText = ""
    @State private var menuItems: [RowViewModel] = []
    @State private var page: Int = 0
    @State private var isLoading = false
    
    var searchResults: [RowViewModel] {
           if searchText.isEmpty {
               return menuItems
           } else {
               return menuItems.filter {
                   $0.firstName.lowercased().contains(searchText.lowercased()) ||
                   $0.lastName.lowercased().contains(searchText.lowercased())
               }
           }
       }
    
    var body: some View {
        NavigationView {
            List(searchResults) { item in
                NavigationLink(destination: UserDetailView(userID: item.id, menuItems: $menuItems)) {
                    RowView(model: item)
                        .listRowSeparator(.hidden)
                        .onAppear(perform: {
                            if self.menuItems.last == item {
                                loadMoreItem()
                            }
                        })
                }
            }
            .navigationTitle("List User")
            .searchable(text: $searchText)
            .onAppear(perform: loadMoreItem)
        }
    }
    
    func loadMoreItem() {
        guard !isLoading else { return }
        Task {
            do {
                isLoading = true
                let items = try await APIManager.getUserList(for: page)
                self.menuItems.append(contentsOf: items)
                self.page += 1
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}

struct GetUserData: Codable {
    var data: [RowViewModel]
}
