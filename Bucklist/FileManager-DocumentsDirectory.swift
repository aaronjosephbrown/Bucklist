//
//  FileManager-DocumentsDirectory.swift
//  Bucklist
//
//  Created by Aaron Brown on 10/11/23.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return paths
    }
}
