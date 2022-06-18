//
//  DetailView.swift
//  YEDUHomeTest
//
//  Created by MACBOOK on 18/06/2022.
//

import SwiftUI

struct UserDetailView: View {
    @State var userModel: UserDetailViewModel?
    @State var userID: String
    @State private var isUpdating: Bool = false
    @State private var isDeleting: Bool = false
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    
    @Binding var menuItems: [RowViewModel]
    @Environment(\.presentationMode) var presentation
    
    
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                if let userModel = userModel {
                    AsyncImage(url: URL(string: userModel.picture))
                        .frame(width: 160, height: 160)
                        .aspectRatio(contentMode: .fit)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                        .clipped()
                        .padding()
                    HStack(alignment: .center, spacing: 20) {
                        Text("FIRSTNAME")
                        if isUpdating {
                            TextField(userModel.firstName, text: $firstName)
                                .onAppear(perform: {
                                    self.firstName = userModel.firstName
                                })
                        } else {
                            Text(userModel.firstName)
                        }
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 20) {
                        Text("LASTNAME")
                        if isUpdating {
                            TextField(userModel.lastName, text: $lastName)
                                .onAppear(perform: {
                                    self.lastName = userModel.lastName
                                })
                        } else {
                            Text(userModel.lastName)
                        }
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 20) {
                        Text("EMAIL")
                        Text(userModel.email)
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 20) {
                        Text("DATE OF BIRTH")
                        Text(userModel.dateOfBirth.getDate(), style: .date)
                        Spacer()
                    }
                    Spacer()
                    Button(isUpdating ? "SAVE":"CHANGE NAME", role: .none, action: changeName)
                        .frame(minWidth: 100, idealWidth: 300, maxWidth: 300, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
                        .background()
                        .cornerRadius(10)
                        .shadow(color: .black, radius: 2, x: 0, y: 2)
                        .font(Font.headline.bold())
                        .foregroundColor(.black)
                    Button("DELETE USER", role: .destructive, action: deleteUser)
                        .frame(minWidth: 100, idealWidth: 300, maxWidth: 300, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(color: .black, radius: 2, x: 0, y: 2)
                        .font(Font.headline.bold())
                        .foregroundColor(.white)
                } else {
                    ProgressView()
                }
            }
            .padding(40)
            .navigationTitle("Detail View")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                do {
                    let userModel = try await APIManager.getUserDetail(for: userID)
                    self.userModel = userModel
                } catch {
                    print(error)
                }
            }
            
            if isDeleting {
                ProgressView()
            }
        }
    }
    
    func changeName() {
        if isUpdating {
            guard (userModel?.firstName != firstName) || (userModel?.lastName != lastName)
            else {
                self.isUpdating.toggle()
                return
            }
            Task {
                do {
                    let updatedModel = try await APIManager.updateUser(for: userID, firstName: firstName, lastName: lastName)
                    self.userModel = updatedModel
                    
                    if let index = self.menuItems.firstIndex(where: { $0.id == userID }),
                       var item = self.menuItems.first(where: { $0.id == userID }) {
                        item.firstName = firstName
                        item.lastName = lastName
                        self.menuItems.removeAll(where: { $0.id == userID })
                        self.menuItems.insert(item, at: index)
                    }
                } catch {
                    print(error)
                }
            }
        }
        self.isUpdating.toggle()
    }
    
    func deleteUser() {
        self.isDeleting.toggle()
        Task {
            do {
                if try await APIManager.deleteUser(for: userID) {
                    print("Deleted")
                    self.menuItems = self.menuItems.filter({ $0.id != userID })
                }
            } catch {
                print(error)
            }
            self.isDeleting.toggle()
            DispatchQueue.main.async {
                self.presentation.wrappedValue.dismiss()
            }
        }
    }
}


struct UserDetailViewModel: Codable, Hashable, Identifiable {
    var id: String
    var title: String
    var firstName: String
    var lastName: String
    var picture: String
    var email: String
    var dateOfBirth: String
}

struct DeleteUserModel: Codable, Hashable, Identifiable {
    var id: String
}

let userSampleModel = UserDetailViewModel(id: "60d0fe4f5311236168a109ca", title: "ms", firstName: "Sara", lastName: "Andersen", picture: "https://randomuser.me/api/portraits/women/58.jpg", email: "milly.norman@example.com", dateOfBirth: "1975-08-25T06:11:36.092Z")


fileprivate extension String {
    func getDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: self)!
    }
}
