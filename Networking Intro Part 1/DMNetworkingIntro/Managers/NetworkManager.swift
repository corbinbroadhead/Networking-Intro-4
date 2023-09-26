//
//  NetworkManager.swift
//  DMNetworkingIntro
//
//  Created by David Ruvinskiy on 4/10/23.
//

import Foundation

/**
 3.1 Create a protocol called `NetworkManagerDelegate` that contains a function called `usersRetrieved`.. This function should accept an array of `User` and should not return anything.
 */
protocol NetworkManagerDelegate {
    func usersRetrieved(users: [User])
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseUrl = "https://reqres.in/api/"
    
    private init() {}
    
    /**
     3.2 Create a variable called `delegate` of type optional `NetworkManagerDelegate`. We will be using the delegate to pass the `Users` to the `UsersViewController` once they come back from the API.
     */
    var delegate: NetworkManagerDelegate?
    /**
     3.3 Make a request to the API and decode the JSON that comes back into a `UserResponse` object.
     3.4 Call the `delegate`'s `usersRetrieved` function, passing the `data` array from the decoded `UserResponse`.
     
     This is a tricky function, so some starter code has been provided.
     */
    func getUsers(completed: @escaping (Result<[User], DMError>) -> Void) {
        
        // 3.3 Append the "/users" endpoint to the base URL and store the result in a variable. You should end up with this String: "https://reqres.in/api/users".
        let urlExtended = baseUrl + "users"
        // 3.3 Create a `URL` object from the String. If the `URL` is nil, break out of the function.
        guard let url = URL(string: urlExtended) else {
            return completed(.failure(.invalidURL))
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 3.3 If the error is not nil, break out of the function.
            if error != nil {
                return completed(.failure(.invalidData))
            }
            // 3.3 Unwrap the data. If it is nil, break out of the function.
            guard let data else {
                return completed(.failure(.invalidResponse))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // 3.3 Use the provided `decoder` to decode the data into a `UserResponse` object.
                let usersData = try decoder.decode(UserResponse.self, from: data)
                // 3.4 Call the `delegate`'s `usersRetrieved` function, passing the `data` array from the decoded `UserResponse`.
                self.delegate?.usersRetrieved(users: usersData.data)
                return completed(.success(usersData.data))
            } catch {
                print("Error during decoding, \(error)")
                return completed(.failure(.unableToComplete))
            }
        }
        
        task.resume()
    }
}
