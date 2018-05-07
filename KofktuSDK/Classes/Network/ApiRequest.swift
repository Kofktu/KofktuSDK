//
//  ApiRequest.swift
//  KofktuSDK
//
//  Created by Kofktu on 2018. 5. 7..
//  Copyright © 2018년 Kofktu. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

public enum ApiRequestError: LocalizedError {
    case unknown(Int?)
    case invalidParameter
    case retry
    case emptyResponse
    
    public var errorDescription: String? {
        switch self {
        case .unknown(let statusCode):
            return "네트워크 상황이 불안정하거나 서버문제로 데이터를 불러오지 못했습니다.(\(statusCode ?? -1))"
        case .invalidParameter:
            return "일시적인 오류가 발생했습니다.\n잠시 후에 다시 시도해주세요."
        case .emptyResponse:
            return "데이터가 없습니다."
        default:
            return nil
        }
    }
}

private class ApiRequestPool: MultiContentUsable {
    static let pool = ApiRequestPool()
    
    typealias Content = ApiRequest
    var contents: [Content]?
    
    init() {
        contents = [Content]()
    }
    
    func add(request: Content) {
        if contents?.contains(request) ?? false {
            return
        }
        contents?.append(request)
    }
    
    func remove(request: Content) {
        contents?.remove(object: request)
    }
    
}

open class ApiRequest: NSObject, ApiRequestProtocol, RetryEnable {
    
    public var api: Api
    public var baseURL: URL
    public var method: Alamofire.HTTPMethod
    public var timeoutIntervalForRequest: TimeInterval
    
    public var resourcePath: String {
        return api.resourcePath
    }
    
    /**
     * JSONEncoding.default
     * URLEncoding.default
     * ArrayEncoding.default
     */
    public var encoding: Alamofire.ParameterEncoding {
        return api.encoding
    }
    
    public var retryCount: Int = 0
    static var isRefreshingToken = false
    
    public init(api: Api) {
        self.api = api
        self.baseURL = URL(string: api.rootURL.urlString)!
        self.method = api.method
        self.timeoutIntervalForRequest = api.timeoutInterval.rawValue
    }
    
    open func execute(_ parameters: ApiParameterization? = nil, headers: HTTPHeaders? = nil) -> DataRequest {
        return ApiManager.sharedManager.request(apiRequest: self, parameters: parameters?.parameters, headers: headers)
    }
    
    open func responseErrorHandler(data: Data?, statusCode: Int?) throws {
    }
    
    @discardableResult
    open func execute<T: BaseMappable>(_ parameters: ApiParameterization?, headers: HTTPHeaders? = nil, completion: @escaping (T?, Error?) -> Void) -> URLSessionDataTask? {
        ApiRequestPool.pool.add(request: self)
        return execute(parameters, headers: headers).responseJSON(completionHandler: { [unowned self] (response) in
            switch response.result {
            case .success(let value):
                DispatchQueue.global(qos: .userInitiated).async(execute: {
                    let result = Mapper<T>().map(JSONObject: value)
                    
                    dispatch_main_safe(async: {
                        completion(result, nil)
                        ApiRequestPool.pool.remove(request: self)
                    })
                })
            case .failure(let error):
                do {
                    try self._responseErrorHandler(data: response.data, statusCode: response.response?.statusCode)
                    completion(nil, error)
                    ApiRequestPool.pool.remove(request: self)
                } catch ApiRequestError.retry {
                    self.execute(parameters, completion: completion)
                } catch ApiRequestError.emptyResponse {
                    completion(nil, ApiRequestError.emptyResponse)
                    ApiRequestPool.pool.remove(request: self)
                } catch {
                    completion(nil, error)
                    ApiRequestPool.pool.remove(request: self)
                }
            }
        }).task as? URLSessionDataTask
    }
    
    @discardableResult
    open func execute<T: BaseMappable>(objects parameters: ApiParameterization?, headers: HTTPHeaders? = nil, completion: @escaping ([T]?, Error?) -> Void) -> URLSessionDataTask? {
        ApiRequestPool.pool.add(request: self)
        return execute(parameters, headers: headers).responseJSON(completionHandler: { [unowned self] (response) in
            switch response.result {
            case .success(let value):
                DispatchQueue.global(qos: .userInitiated).async(execute: {
                    let result = Mapper<T>().mapArray(JSONObject: value)
                    
                    dispatch_main_safe(async: {
                        completion(result, nil)
                        ApiRequestPool.pool.remove(request: self)
                    })
                })
            case .failure(let error):
                do {
                    try self._responseErrorHandler(data: response.data, statusCode: response.response?.statusCode)
                    completion(nil, error)
                    ApiRequestPool.pool.remove(request: self)
                } catch ApiRequestError.retry {
                    self.execute(objects: parameters, completion: completion)
                } catch ApiRequestError.emptyResponse {
                    completion(nil, ApiRequestError.emptyResponse)
                    ApiRequestPool.pool.remove(request: self)
                } catch {
                    completion(nil, error)
                    ApiRequestPool.pool.remove(request: self)
                }
            }
        }).task as? URLSessionDataTask
    }
    
    @discardableResult
    open func execute<T>(json parameters: ApiParameterization?, headers: HTTPHeaders? = nil, completion: @escaping (T?, Error?) -> Void) -> URLSessionDataTask? {
        ApiRequestPool.pool.add(request: self)
        return execute(parameters, headers: headers).responseJSON(completionHandler: { [unowned self] (response) in
            switch response.result {
            case .success(let value):
                completion(value as? T, nil)
                ApiRequestPool.pool.remove(request: self)
            case .failure(let error):
                do {
                    try self._responseErrorHandler(data: response.data, statusCode: response.response?.statusCode)
                    completion(nil, error)
                    ApiRequestPool.pool.remove(request: self)
                } catch ApiRequestError.retry {
                    self.execute(json: parameters, completion: completion)
                } catch ApiRequestError.emptyResponse {
                    completion(nil, ApiRequestError.emptyResponse)
                    ApiRequestPool.pool.remove(request: self)
                } catch {
                    completion(nil, error)
                    ApiRequestPool.pool.remove(request: self)
                }
            }
        }).task as? URLSessionDataTask
    }
    
    @discardableResult
    open func execute(`default` parameters: ApiParameterization?, headers: HTTPHeaders? = nil, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask? {
        ApiRequestPool.pool.add(request: self)
        return execute(parameters, headers: headers).response(completionHandler: { [unowned self] (response) in
            if let error = response.error {
                do {
                    try self._responseErrorHandler(data: response.data, statusCode: response.response?.statusCode)
                    completion(nil, error)
                    ApiRequestPool.pool.remove(request: self)
                } catch ApiRequestError.retry {
                    self.execute(default: parameters, completion: completion)
                } catch ApiRequestError.emptyResponse {
                    completion(nil, ApiRequestError.emptyResponse)
                    ApiRequestPool.pool.remove(request: self)
                } catch {
                    completion(nil, error)
                    ApiRequestPool.pool.remove(request: self)
                }
            } else {
                completion(response.data, response.error)
                ApiRequestPool.pool.remove(request: self)
            }
        }).task as? URLSessionDataTask
    }
    
    // MARK: - Private
    private func _responseErrorHandler(data: Data?, statusCode: Int?) throws {
        retryCount += 1
        
        if let _ = data, let statusCode = statusCode, 200 ..< 300 ~= statusCode {
            throw ApiRequestError.emptyResponse
        }
        
        if canRetry {
            throw ApiRequestError.retry
        }
        
        try responseErrorHandler(data: data, statusCode: statusCode)
        
        throw ApiRequestError.unknown(statusCode)
    }
    
}
