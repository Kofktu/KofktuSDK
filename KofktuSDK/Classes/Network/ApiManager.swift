//
//  ApiManager.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Alamofire
import Timberjack

public protocol ApiRequestProtocol {
    var baseURL: NSURL { get }
    var method: Alamofire.Method { get }
    var timeoutIntervalForRequest: NSTimeInterval { get }
    var resourcePath: String { get }
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
    
    public static var style: Style = .Light
    
    private var headers = [String: String]()
    private var managerInfo = Dictionary<NSTimeInterval, Alamofire.Manager>()
    
    public func error(code: Int = NSURLErrorUnknown, description: String) -> NSError {
        return NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    public func addHTTPHeader(value: String, field: String) {
        headers[field] = value
    }
    
    public func removeHTTPHeader(field: String) {
        headers.removeValueForKey(field)
    }
    
    public func manager(apiRequest: ApiRequestProtocol) -> Alamofire.Manager {
        if let manager = managerInfo[apiRequest.timeoutIntervalForRequest] { return manager }
        
        let create: (NSURLSessionConfiguration) -> Alamofire.Manager = { (configuration) in
            configuration.timeoutIntervalForRequest = apiRequest.timeoutIntervalForRequest
            let manager = Alamofire.Manager(configuration: configuration)
            self.managerInfo[apiRequest.timeoutIntervalForRequest] = manager
            return manager
        }
        
        if ApiManager.style == .Light {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            return create(configuration)
        } else {
            Timberjack.logStyle = ApiManager.style
            let configuration = Timberjack.defaultSessionConfiguration()
            return create(configuration)
        }
    }
    
    public func request(apiRequest: ApiRequestProtocol, parameters: AnyObject? = nil) -> Request {
        let urlString = NSURL(string: apiRequest.resourcePath, relativeToURL: apiRequest.baseURL)!.absoluteString
        
        switch apiRequest.method {
        case .GET, .HEAD:
            return manager(apiRequest).request(apiRequest.method, urlString!, parameters: parameters as? Dictionary<String, AnyObject>, headers: headers).validate()
        default:
            return manager(apiRequest).request(apiRequest.method, urlString!, parameters: [:], encoding: .Custom({ (convertible, params) -> (NSMutableURLRequest, NSError?) in
                let mutableRequest: NSMutableURLRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
                if let parameters = parameters {
                    do {
                        mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions(rawValue: 0))
                    } catch {}
                }
                return (mutableRequest, nil)
            }), headers: headers).validate()
        }
    }
    
    public func upload(apiRequest: ApiRequestProtocol, data: NSData) -> Request {
        let urlString = NSURL(string: apiRequest.resourcePath, relativeToURL: apiRequest.baseURL)!.absoluteString
        return manager(apiRequest).upload(apiRequest.method, urlString!, headers: headers, data: data).validate()
    }
}
