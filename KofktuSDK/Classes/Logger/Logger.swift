//
//  Logger.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation

public enum Style {
    case none
    case light
    case verbose
}

open class Logger: URLProtocol {
    open static let shared: Logger = {
        return Logger()
    }()
    open static var style: Style = .light
    
    // MARK: - Log
    open func d<T>(_ value: T, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard Logger.style == .verbose else { return }
        print("\(file.lastPathComponent).\(function)[\(line)] : \(value)", terminator: "\n")
    }
    
    open func e(_ error: NSError?, file: NSString = #file, function: String = #function, line: Int = #line) {
        guard Logger.style != .none else { return }
        if let error = error {
            print("\(file.lastPathComponent).\(function)[\(line)] : ===========[ERROR]============", terminator: "\n")
            print("Code : \(error.code)", terminator: "\n")
            print("Description : \(error.localizedDescription)", terminator: "\n")
            
            if Logger.style == .verbose {
                if let reason = error.localizedFailureReason {
                    print("Reason : \(reason)", terminator: "\n")
                }
                if let suggestion = error.localizedRecoverySuggestion {
                    print("Suggestion : \(suggestion)", terminator: "\n")
                }
            }
            print("==============================================================================", terminator: "\n")
        } else {
            print("\(file.lastPathComponent).\(function)[\(line)] : [ERROR] error is null", terminator: "\n")
        }
    }
    
    // MARK: - Network Log
    open static var defaultSession: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(Logger.self, at: 0)
        return config
    }
    
    fileprivate var connection: NSURLConnection?
    fileprivate var data: NSMutableData?
    fileprivate var response: URLResponse?
    fileprivate var newRequest: NSMutableURLRequest?
}

let LoggerRequestHandledKey = "Logger"
let LoggerRequestTimeKey = "LoggerRequestTime"

extension Logger: NSURLConnectionDataDelegate {
    
    open class func register() {
        URLProtocol.registerClass(self)
    }
    
    open class func unregister() {
        URLProtocol.unregisterClass(self)
    }
    
    // MARK: - Private
    fileprivate func logError(_ error: NSError) {
        Log?.e(error)
    }
    
    fileprivate func logDivider() {
        guard Logger.style != .none else { return }
        print("---------------------")
    }
    
    fileprivate func logHeaders(_ headers: [String: AnyObject]) {
        print("Headers: [")
        for (key, value) in headers {
            print("  \(key) : \(value)")
        }
        print("]")
    }
    
    fileprivate func logRequest(_ request: URLRequest) {
        logDivider()
        
        if let url = request.url?.absoluteString, let method = request.httpMethod {
            print("Request: \(method) \(url)")
        }
        
        guard Logger.style == .verbose else { return }
        
        if let headers = request.allHTTPHeaderFields {
            logHeaders(headers as [String : AnyObject])
        }
        
        if let body = request.httpBody {
            print("Body: [")
            do {
                let json = try JSONSerialization.jsonObject(with: body, options: .mutableContainers)
                let pretty = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                
                if let jsonString = String(data: pretty, encoding: .utf8) {
                    print("JSON : \(jsonString)")
                }
            } catch {
                if let formString = String(data: body, encoding: .utf8) {
                    print("FORM : \(formString)")
                }
            }
            print("]")
        }
    }

    fileprivate func logResponse(_ response: URLResponse, data: Data? = nil) {
        logDivider()
        
        if let url = response.url?.absoluteString {
            print("Response: \(url)")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            let localisedStatus = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode).capitalized
            print("Status: \(httpResponse.statusCode) - \(localisedStatus)")
        }
        
        guard Logger.style == .verbose else { return }
        
        if let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: AnyObject] {
            logHeaders(headers)
        }
        
        if let newRequest = newRequest, let startDate = Logger.property(forKey: LoggerRequestTimeKey, in: newRequest as URLRequest) as? Date {
            let difference = fabs(startDate.timeIntervalSinceNow)
            print("Duration: \(difference)s")
        }
        
        guard let data = data else { return }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let pretty = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            if let string = NSString(data: pretty, encoding: String.Encoding.utf8.rawValue) {
                print("JSON: \(string)")
            }
        }
            
        catch {
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print("Data: \(string)")
            }
        }
    }
    
    //MARK: - NSURLProtocol
    open override class func canInit(with request: URLRequest) -> Bool {
        guard self.property(forKey: LoggerRequestHandledKey, in: request) == nil else {
            return false
        }
        return true
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    open override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }

    open override func startLoading() {
        guard let req = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest, newRequest == nil else { return }
        
        self.newRequest = req
        
        Logger.setProperty(true, forKey: LoggerRequestHandledKey, in: req)
        Logger.setProperty(Date(), forKey: LoggerRequestTimeKey, in: req)
        
        connection = NSURLConnection(request: req as URLRequest, delegate: self)
        
    }
    
    open override func stopLoading() {
        connection?.cancel()
        connection = nil
    }
    
    // MARK: NSURLConnectionDelegate
    public func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        
        self.response = response
        self.data = NSMutableData()
    }
    
    public func connection(_ connection: NSURLConnection, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        self.data?.append(data)
    }
    
    public func connectionDidFinishLoading(_ connection: NSURLConnection) {
        client?.urlProtocolDidFinishLoading(self)
        
        if let response = response {
            logResponse(response, data: data as Data?)
        }
    }
    
    public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        client?.urlProtocol(self, didFailWithError: error)
        logError(error as NSError)
    }
}

public let Log: Logger? = {
    guard Logger.style != .none else { return nil }
    return Logger.shared
}()

