//
//  ApiManager.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Alamofire
import Sniffer
import CocoaDebug

public protocol ApiRequestProtocol {
    var baseURL: URL { get }
    var method: Alamofire.HTTPMethod { get }
    var timeoutIntervalForRequest: TimeInterval { get }
    var resourcePath: String { get }
    /**
     * JSONEncoding.default
     * URLEncoding.default
     * ArrayEncoding.default
     */
    var encoding: Alamofire.ParameterEncoding { get }
}

public class ApiManager {
    
    public static let sharedManager = ApiManager()
    public private(set) var headers = HTTPHeaders()
    
    private var managerInfo = Dictionary<TimeInterval, Alamofire.SessionManager>()
    
    public func error(code: Int = NSURLErrorUnknown, description: String) -> NSError {
        return NSError(domain: Bundle.main.bundleIdentifier!, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    public func add(header value: String, field: String) {
        headers[field] = value
    }
    
    public func remove(header field: String) {
        headers[field] = nil
    }
    
    public func manager(_ apiRequest: ApiRequestProtocol) -> Alamofire.SessionManager {
        if let manager = managerInfo[apiRequest.timeoutIntervalForRequest] { return manager }
        
        let create: (URLSessionConfiguration) -> Alamofire.SessionManager = { (configuration) in
            configuration.timeoutIntervalForRequest = apiRequest.timeoutIntervalForRequest
            let manager = Alamofire.SessionManager(configuration: configuration)
            self.managerInfo[apiRequest.timeoutIntervalForRequest] = manager
            return manager
        }
        
        let configuration = URLSessionConfiguration.`default`
        
        if Log.isEnabled {
            Sniffer.enable(in: configuration)
        }
        
        return create(configuration)
    }
    
    public func request(apiRequest: ApiRequestProtocol, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) -> DataRequest {
        let urlString = URL(string: apiRequest.resourcePath, relativeTo: apiRequest.baseURL)!.absoluteString
        var header = self.headers
        if let headers = headers {
            header.merge(dict: headers)
        }
        switch apiRequest.method {
        case .get, .head:
            return manager(apiRequest).request(urlString, method: apiRequest.method, parameters: parameters, headers: header).validate()
        default:
            return manager(apiRequest).request(urlString, method: apiRequest.method, parameters: parameters, encoding: apiRequest.encoding, headers: header).validate()
        }
    }
    
    public func upload(apiRequest: ApiRequestProtocol, data: Data) -> DataRequest {
        let urlString = URL(string: apiRequest.resourcePath, relativeTo: apiRequest.baseURL)!.absoluteString
        return manager(apiRequest).upload(data, to: urlString, method: apiRequest.method, headers: headers).validate()
    }
}

/**
 * ParameterEncoding for Array
 * http://stackoverflow.com/questions/27026916/sending-json-array-via-alamofire
 */
private let parameterEncodingForArrayKey = "parameterEncodingForArrayKey"

extension Array {
    func asParameters() -> Parameters {
        return [parameterEncodingForArrayKey: self]
    }
}

public struct ArrayEncoding: ParameterEncoding {
    public let options: JSONSerialization.WritingOptions
    
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters, let array = parameters[parameterEncodingForArrayKey] else {
            return urlRequest
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}
