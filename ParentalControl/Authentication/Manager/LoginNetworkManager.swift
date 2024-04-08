//
//  LoginNeworkManager.swift
//  CorenrollDemo
//
//  Created by Punit Thakali on 11/12/2023.
//
import Foundation

struct ApiUrl {
    static let baseURL = "https://qa-api.purenroll.com/api/v1/auth"

    static func getLoginURL() -> URL {
        return URL(string: "\(baseURL)/login")!
    }
}

class LoginNetworkManager {
    
    static let shared = LoginNetworkManager()
    
    private init() {}

    func login(model: LoginModel, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let url = ApiUrl.getLoginURL()
    
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let apiModel = model
        
        do {
            let jsonData = try JSONEncoder().encode(apiModel)
            request.httpBody = jsonData
        }
        catch {
            completion(.failure(error))
            return
        }

        // Print the request details using the debug() function
        print("REQUEST: ==============================")
        request.debug()
        print("================= ==============================")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                guard (200 ... 299) ~= httpResponse.statusCode else {
                    print("RESPONSE: ==============================")
                    print("Status code: \(httpResponse.statusCode)")
                    let jsonString = try? JSONSerialization.jsonObject(with: data)
                    print(jsonString!)
                    print("================= ==============================")
                    return
                }

                switch httpResponse.statusCode {
                case 200 ... 299:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                        completion(.success(()))
                    } catch {
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                case 401:
                    completion(.failure(NSError(domain: "UnauthorizedError", code: 401, userInfo: nil)))
                case 422:
                    completion(.failure(NSError(domain: "UnprocessableEntityError", code: 422, userInfo: nil)))
                default:
                    completion(.failure(NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: nil)))
                }
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

extension URLRequest {
    func debug() {
        print("\(self.httpMethod ?? "") \(self.url?.absoluteString ?? "")")
        print("Headers:")
        print(self.allHTTPHeaderFields ?? "")
        print("Body:")
        print(String(data: self.httpBody ?? Data(), encoding: .utf8) ?? "")
    }
}
