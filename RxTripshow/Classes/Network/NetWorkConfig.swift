//
//  NetWorkConfig.swift
//  RxTripshow
//
//  Created by aby on 2018/8/20.
//  Copyright © 2018 aby. All rights reserved.
//
import RxSwift
import Moya

enum Api {
    case getHomeVideoList(page: Int, session: String?)
    case getVideoList(label: Int, order: String, session: String?, page: Int)
    case getChannelList(page: Int) // 请求频道列表
    case getAuthorInfo
    case videoDetail(id: Int, session: String?)
    case like(videoID: Int, session: String)
    case userInfo(String)
    case myFavoriteList
    case login(mobile: String, pwd: String)
    case sendCode
    case registerAction
    case weChatLogin
    case report
}

extension Api: TargetType {
    // 拼接字符
    var path: String {
        switch self {
        case .getHomeVideoList:
            return "/index.json"
        case .getVideoList:
            return "/videoList.json"
        case .getChannelList:
            return "/labelList.json"
        case .getAuthorInfo:
            return "/owner.json"
        case .videoDetail:
            return "/video.json"
        case .like:
            return "/like_video.json"
        case .userInfo:
            return "user_info.json"
        case .myFavoriteList:
            return "/mylikes.json"
        case .login:
            return "/register_mobileLogin.json"
        case .sendCode:
            return "/register_sendMobileVcode.json"
        case .registerAction:
            return "/register_mobileReg.json"
        case .weChatLogin:
            return "/register_wechat.json"
        case .report:
            return "/complaint.json"
        }
    }

    var method: Moya.Method {
        return .post
    }

    // 只有在测试文件中起作用
    var sampleData: Data {
        return "{}".data(using: .utf8)!

    }

    var task: Task {
        var params: [String: Any] = [:]
        params["version"] = "1.0.1"
        params["platform"] = "ios"
        var body: [String: Any] = [:]
        switch self {
        case let .getHomeVideoList(page: page, session: session):
            body["page"] = page
            if let ses = session {
                body["userSession"] = ses
            }
            return .requestCompositeParameters(bodyParameters: body, bodyEncoding: URLEncoding.httpBody, urlParameters: params)
        case let .getChannelList(page: page):
            body["page"] = page
            return .requestCompositeParameters(bodyParameters: body, bodyEncoding: URLEncoding.httpBody, urlParameters: params)
        case let .login(mobile: mobile, pwd: pwd):
            body["mobile"] = Int(mobile) ?? 0
            body["password"] = pwd
            return .requestCompositeParameters(bodyParameters: body, bodyEncoding: URLEncoding.httpBody, urlParameters: params)
        case .userInfo(let session):
            body["userSession"] = session
            return .requestCompositeParameters(bodyParameters: body, bodyEncoding: URLEncoding.httpBody, urlParameters: params)
        case let .like(videoID: id, session: session):
            body["videoID"] = id
            body["userSession"] = session
            return .requestCompositeParameters(bodyParameters: body, bodyEncoding: URLEncoding.httpBody, urlParameters: params)
        case .videoDetail(id: let id, session: let session):
            body["id"] = id
            body["userSession"] = session
            return .requestCompositeParameters(bodyParameters: body, bodyEncoding: URLEncoding.httpBody, urlParameters: params)
        case let .getVideoList(label:label, order: order, session: session, page: page):
            body["label"] = label
            body["userSession"] = session
            body["order"] = order
            body["page"] = page
            return .requestCompositeParameters(bodyParameters: body, bodyEncoding: URLEncoding.httpBody, urlParameters: params)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return [
            "Accept": "*/*"
        ]
    }

    // 基本请求域名
    var baseURL: URL {
        return URL.init(string: "http://app.tripshow.com/api")!
    }

}
