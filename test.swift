#!/usr/bin/env swift
import Foundation

func promptForTemplate() -> String {
    let templatePairs: [(title: String, value: String)] = [
        (title: "TCA Template", value: "xxPROJECTxNAMExx"),
        (title: "SPM Template", value: "xxSPMxNAMExx")
    ]

    print("请选择模版：")
    for (index, option) in templatePairs.enumerated() {
        print("\(index + 1). \(option.title)(\(option.value))")
    }

    guard let input = readLine(),
          let choice = Int(input),
          (1...templatePairs.count).contains(choice) else {
        print("❌ 无效输入")
        exit(1)
    }
    return templatePairs[choice - 1].value
}
