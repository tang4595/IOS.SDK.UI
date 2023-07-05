//
//  AmaniUIDelegate.swift
//  AmaniUIv1
//
//  Created by Münir Ketizmen on 26.12.2022.
//

import Foundation
import AmaniSDK
public protocol AmaniUIDelegate: AnyObject {
    func onKYCSuccess(CustomerId:String)
    func onKYCFailed(CustomerId:String,Rules:[[String:String]]?)
  ///TODO: Token Expired delegate needed to be comes from AmaniV3
//    func onTokenExpired()
//    func onNoInternetConnection()
//    func onEvent(name:String,Parameters:[String]?,type:String)
}
