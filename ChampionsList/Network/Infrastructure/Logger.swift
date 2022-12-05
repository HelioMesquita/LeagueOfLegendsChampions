import Foundation

class Logger {

    static func show(request: URLRequest, _ output: URLSession.DataTaskPublisher.Output) {
        #if DEBUG
        var requestLog = "REQUEST=================================================\n"
        requestLog += "🎯🎯🎯 URL: \(request.url?.absoluteString ?? "")\n"
        requestLog += "-----------------------------------------------------------\n"
        requestLog += "⚒⚒⚒ HTTP METHOD: \(request.httpMethod ?? "")\n"
        requestLog += "-----------------------------------------------------------\n"
        requestLog += "📝📝📝 HEADERS: \(request.allHTTPHeaderFields ?? [:])\n"
        requestLog += "-----------------------------------------------------------\n"

        requestLog += "RESPONSE================================================\n"
        requestLog += "⚠️⚠️⚠️ STATUS CODE: \((output.response as? HTTPURLResponse)?.statusCode ?? 0)\n"
        requestLog += "-----------------------------------------------------------\n"
        requestLog += "📒📒📒 HEADERS: \((output.response as? HTTPURLResponse)?.allHeaderFields as? [String: String] ?? [:])\n"
        requestLog += "-----------------------------------------------------------\n"

        do {
            let json = try JSONSerialization.jsonObject(with: output.data, options: .mutableContainers)
            let prettyPrintedData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            requestLog += "⬇️⬇️⬇️ RESPONSE DATA: \n\(String(bytes: prettyPrintedData, encoding: .utf8) ?? "")"
        } catch {
            requestLog += "⬇️⬇️⬇️ RESPONSE DATA: \n\(String(data: output.data, encoding: .utf8) ?? "")"
            requestLog += "\n===========================================================\n"
        }

        print(requestLog)
        #endif
    }

}
