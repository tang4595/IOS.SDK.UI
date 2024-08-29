//
//  UtilityModels.swift
//  AmaniUIv1
//
//  Created by Deniz Can on 7.09.2022.
//

struct LocalErrorModel {
  var value: Bool
  var docType: String
}

enum DocumentID: String {
  // Id card
  case ID = "ID"
  // NFC as a document
  case NF = "NF"
  // Selfie
  case SE = "SE"
  // Driver's licence
  case DL = "DL"
  // Passport
  case PA = "PA"
  // Contract
  case CO = "CO"
  // Utility Bill
  case UB = "UB"
  // Proof of address
  case IB = "IB"
  // Signature
  case SG = "SG"
  // Visa
  case VA = "VA"
}
