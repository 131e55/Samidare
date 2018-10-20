//
//  dprint.swift
//  https://github.com/131e55/dprint.swift
//

import Foundation

func dprint(_ items: Any..., separator: String = " ", terminator: String = "\n",
            file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let item = items.map({ "\($0)" }).joined(separator: separator)
    let filename = file.components(separatedBy: "/").last!
    print("<\(filename):\(function):\(line)> \(item)", terminator: terminator)
    #endif
}
