//
//  APIManager.swift
//  YEDUHomeTest
//
//  Created by MACBOOK on 15/06/2022.
//

import UIKit
import SwiftUI

enum Error: Swift.Error {
    case requestFailed
}

final class APIManager {
    
    static let baseURLString = "https://dummyapi.io/data/v1"
    
    //Get list of user using pagination
    static func getUserList(for page: Int = 0) async throws -> [RowViewModel] {
        // Build up the URL
        let url = URL(string: baseURLString.appending("/user"))!
            .appendingQuerry("page", value: "\(page)")
        var request = URLRequest(url: url)
        request.setValue(
            "6289ff90882cab1e04caa689",
            forHTTPHeaderField: "app-id")
        
        // Generate and execute the request
        var listItems: [RowViewModel] = []
        let (data, _) = try await URLSession.shared.data(for: request)
        listItems = try JSONDecoder()
            .decode(GetUserData.self, from: data).data
        
        return listItems
    }
    
    //Get user detail by id
    static func getUserDetail(for id: String) async throws -> UserDetailViewModel {
        // Build up the URL
        let url = URL(string: baseURLString.appending("/user").appending("/\(id)"))!
        var request = URLRequest(url: url)
        request.setValue(
            "6289ff90882cab1e04caa689",
            forHTTPHeaderField: "app-id")
        
        // Generate and execute the request
        let (data, _) = try await URLSession.shared.data(for: request)
        let userModel = try JSONDecoder()
            .decode(UserDetailViewModel.self, from: data)
        return userModel
    }
    
    
    //Update user name
    static func updateUser(for id: String, firstName: String, lastName: String) async throws -> UserDetailViewModel {
        // Prepare body data
        var json: [String: Any] = [:]
        if !firstName.isEmpty {
            json["firstName"] = firstName
        }
        if !lastName.isEmpty {
            json["lastName"] = lastName
        }
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // Build up the URL
        let url = URL(string: baseURLString.appending("/user").appending("/\(id)"))!
        var request = URLRequest(url: url)
        
        request.httpBody = jsonData
        request.httpMethod = "PUT"
        
        //Add headers
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("6289ff90882cab1e04caa689", forHTTPHeaderField: "app-id")
        
        // Generate and execute the request
        let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
        let updatedModel = try JSONDecoder()
            .decode(UserDetailViewModel.self, from: data)
        return updatedModel
    }
    
    //Delete user by ID
    static func deleteUser(for id: String) async throws -> Bool {
        // Build up the URL
        let url = URL(string: baseURLString.appending("/user").appending("/\(id)"))!
        var request = URLRequest(url: url)
        request.setValue(
            "6289ff90882cab1e04caa689",
            forHTTPHeaderField: "app-id")
        request.httpMethod = "DELETE"
        
        // Generate and execute the request
        let (data, _) = try await URLSession.shared.data(for: request)
        let deleteModel = try JSONDecoder()
            .decode(DeleteUserModel.self, from: data)
        return deleteModel.id == id
    }
}

fileprivate extension URL {

    func appendingQuerry(_ queryItem: String, value: String?) -> URL {

        guard var urlComponents = URLComponents(string: absoluteString)
        else { return absoluteURL }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }
}
