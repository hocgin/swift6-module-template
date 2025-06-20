#!/usr/bin/env swift

import Foundation

func promptForVariable(variable: String, defaultValue: String) -> String {
    if variable == "__PROJECT_NAME__", CommandLine.arguments.count == 2 {
        return CommandLine.arguments[1]
    }
    print("Please enter a value for \(variable) (default: \"\(defaultValue)\")")
    if let answer = readLine(), !answer.isEmpty {
        return answer
    }
    return defaultValue
}

func replaceVariablesInFiles(substitutions: [(from: String, to: String)]) {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(atPath: ".")

    while let fileName = enumerator?.nextObject() as? String {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: fileName, isDirectory: &isDirectory), !isDirectory.boolValue {
            do {
                var text = try String(contentsOfFile: fileName, encoding: .utf8)
                for substitution in substitutions {
                    text = text.replacingOccurrences(of: substitution.from, with: substitution.to)
                }
                try text.write(toFile: fileName, atomically: true, encoding: .utf8)
            } catch {
                // Skip this file if it isn’t valid UTF-8
            }
        }
    }
}

func replaceVariablesInFileNames(at path: String, substitutions: [(from: String, to: String)]) {
    let fileManager = FileManager.default

    guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
        return
    }

    for fileName in contents {
        if fileName == "." || fileName == ".." {
            continue
        }

        let fullPath = (path as NSString).appendingPathComponent(fileName)
        var newFileName = fileName
        for substitution in substitutions {
            newFileName = newFileName.replacingOccurrences(of: substitution.from, with: substitution.to)
        }

        let newFullPath = (path as NSString).appendingPathComponent(newFileName)

        // ⚠️ 重命名先于递归
        if newFileName != fileName {
            try? fileManager.moveItem(atPath: fullPath, toPath: newFullPath)
        }

        // 递归进入（注意使用 newFullPath）
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: newFullPath, isDirectory: &isDirectory), isDirectory.boolValue {
            replaceVariablesInFileNames(at: newFullPath, substitutions: substitutions)
        }
    }
}

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

enum Env {
    static let ENV_VARIABLE_PREFIX = "SMT"

    static func fetchSMT(templateVarName: String, defaultValue: String, prompt: (String, String) -> String) -> String {
        let environmentVarName = nameFor(templateVarName: templateVarName)
        if let value = ProcessInfo.processInfo.environment[environmentVarName] {
            return value
        }
        return prompt(templateVarName, defaultValue)
    }

    static func nameFor(templateVarName: String) -> String {
        return "\(ENV_VARIABLE_PREFIX)_\(sanitize(templateVarName: templateVarName))"
    }

    private static func sanitize(templateVarName: String) -> String {
        return templateVarName
            .uppercased()
            .replacingOccurrences(of: "\\W", with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
}

let projectFlag = promptForTemplate()

let yearFormatter = DateFormatter()
yearFormatter.dateFormat = "yyyy"

var substitutionPairs: [(from: String, to: String)] = [
    (from: "\(projectFlag)", to: "MyProject"),
    (from: "__ORGANIZATION NAME__", to: "Awesome Org"),
    (from: "com.AN.ORGANIZATION.IDENTIFIER", to: "in.hocg.app.example"),
    (from: "__AUTHOR NAME__", to: "hocgin"),
    (from: "__TODAYS_DATE__", to: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)),
    (from: "__TODAYS_YEAR__", to: yearFormatter.string(from: Date())),
    (from: "__GITHUB_USERNAME__", to: "hocgin")
]

// Update the values through environment variables or prompts
substitutionPairs = substitutionPairs.map { pair in
    (from: pair.from, to: Env.fetchSMT(templateVarName: pair.from, defaultValue: pair.to, prompt: promptForVariable))
}

func getPair(_ fieldName: String) -> (from: String, to: String)? {
    return substitutionPairs.first(where: { $0.from == fieldName })
}

let fileManager = FileManager.default
let rootPath = fileManager.currentDirectoryPath
fileManager.changeCurrentDirectoryPath(rootPath)

// Create OUTPUT folder and copy your template folder
try! fileManager.createDirectory(atPath: "OUTPUT", withIntermediateDirectories: true, attributes: nil)
try! fileManager.createDirectory(atPath: "OUTPUT/.tmp", withIntermediateDirectories: true, attributes: nil)
try! fileManager.copyItem(atPath: "\(projectFlag)", toPath: "OUTPUT/.tmp/\(projectFlag)")

/// =========== 扩展 InjectionIII ===========
/// @discardableResult
/// func runShell(_ command: String) -> Int32 {
///     let task = Process()
///     task.launchPath = "/bin/bash"
///     task.arguments = ["-c", command]
///     task.launch()
///     task.waitUntilExit()
///     return task.terminationStatus
/// }
///
/// let status = runShell("cd OUTPUT/.tmp/xxPROJECTxNAMExx && xcode-build-server config -workspace *.xcworkspace -scheme App && xcodebuild -resolvePackageDependencies")
/// if status != 0 {
///     /// 需要 brew install xcode-build-server
///     print("Failed to configure or install xcode-build-server")
/// } else {
///     print("打开 InjectionIII，它会在右上角菜单栏中显示一个小图标，选择项目的目录，再次点击小图标，选择 Prepare Project，为项目中所有的 SwiftUI 文件添加注入代码")
///     print("Read More. https://blog.imjp.uk/fxxk-xcode")
/// }
/// =========== 扩展 InjectionIII ===========

// Move into OUTPUT and do variable replacement
fileManager.changeCurrentDirectoryPath("OUTPUT/.tmp")
replaceVariablesInFiles(substitutions: substitutionPairs)
replaceVariablesInFileNames(at: ".", substitutions: substitutionPairs)

// 移动目录
let pair = getPair("\(projectFlag)")
let projectName = pair?.to ?? "MyProject"
fileManager.changeCurrentDirectoryPath(rootPath)
try! fileManager.moveItem(atPath: "OUTPUT/.tmp/\(projectName)", toPath: "OUTPUT/\(projectName)")

print("Done, your project is now ready to use in the OUTPUT/ folder")
