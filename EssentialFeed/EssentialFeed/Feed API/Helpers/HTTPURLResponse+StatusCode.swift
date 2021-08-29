//
//  HTTPURLResponse+StatusCode.swift
//  HTTPURLResponse+StatusCode
//
//  Created by Elon on 20/08/2021.
//

import Foundation

extension HTTPURLResponse {
    private var OK_200: Int { return 200 }

    func isOK() -> Bool {
        return statusCode == OK_200
    }
}
