//
//  ApiManager.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Alamofire
import Timberjack

public enum ApiRequestBodyFormat {
    case Json
    case Form
}

public protocol ApiRequestProtocol {
    var baseURL: URL { get }
    var method: Alamofire.HTTPMethod { get }
    var timeoutIntervalForRequest: TimeInterval { get }
    var resourcePath: String { get }
    /**
     * JSONEncoding.default
     * URLEncoding.default
     */
    var bodyFormat: Alamofire.ParameterEncoding { get }
}

///////////////////////////////////////
// Sample for ApiRequest Struct
///////////////////////////////////////
//struct ApiRequest: ApiRequestProtocol {
//    var api: Api
//    var method: Alamofire.Method
//    var argument1: String?
//    var argument2: String?
//    var query: [String: String]?
//    
//    init(api: Api, method: Alamofire.Method, query: [String: String]? = nil, argument1: String? = nil, argument2: String? = nil) {
//        self.api = api
//        self.method = method
//        self.query = query
//        self.argument1 = argument1
//        self.argument2 = argument2
//    }
//    
//    var resourcePath: String {
//        var resourcePath = api.resourcePath(argument1, argument2: argument2)
//        
//        if let query = query {
//            var queries = [String]()
//            for value in query {
//                queries.append("\(value.0)=\(value.1)")
//            }
//            resourcePath += "?\(queries.joinWithSeparator("&"))"
//        }
//        
//        return resourcePath
//    }
//    
//    var timeoutIntervalForRequest: NSTimeInterval {
//        return api.timeoutIntervalForRequest()
//    }
//}

public class ApiManager {
    
    public static let sharedManager = ApiManager()
    
    public static var style: Style = .light
    
    private var headers = [String: String]()
    private var managerInfo = Dictionary<TimeInterval, Alamofire.SessionManager>()
    
    public func error(code: Int = NSURLErrorUnknown, description: String) -> NSError {
        return NSError(domain: Bundle.main.bundleIdentifier!, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    public func addHTTPHeader(value: String, field: String) {
        headers[field] = value
    }
    
    public func removeHTTPHeader(field: String) {
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
        
        if ApiManager.style == .light {
            let configuration = URLSessionConfiguration.`default`
            return create(configuration)
        } else {
            Timberjack.logStyle = ApiManager.style
            let configuration = Timberjack.defaultSessionConfiguration()
            return create(configuration)
        }
    }
    
    public func request(apiRequest: ApiRequestProtocol, parameters: [String: AnyObject]? = nil) -> Request {
        let urlString = URL(string: apiRequest.resourcePath, relativeTo: apiRequest.baseURL)!.absoluteString
        switch apiRequest.method {
        case .get, .head:
            return manager(apiRequest).request(urlString, method: apiRequest.method, parameters: parameters, headers: headers).validate()
        default:
            return manager(apiRequest).request(urlString, method: apiRequest.method, parameters: parameters, encoding: apiRequest.bodyFormat, headers: headers).validate()
        }
    }
    
    public func upload(apiRequest: ApiRequestProtocol, data: Data) -> Request {
        let urlString = URL(string: apiRequest.resourcePath, relativeTo: apiRequest.baseURL)!.absoluteString
        return manager(apiRequest).upload(data, to: urlString, method: apiRequest.method, headers: headers as HTTPHeaders).validate()
    }
}
