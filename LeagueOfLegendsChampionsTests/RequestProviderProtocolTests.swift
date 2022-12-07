import Quick
import Nimble

@testable import LeagueOfLegendsChampions

class RequestProviderProtocolTests: QuickSpec {

    let subject: RequestProviderProtocol = MockProvider()

    override func spec() {
        super.spec()

        describe("#asURLRequest") {
            it("returns full url") {
                expect(try? self.subject.asURLRequest().url?.absoluteString).to(equal("https://google.host/testando?key=value"))
            }

            it("returns header") {
                expect(try? self.subject.asURLRequest().allHTTPHeaderFields).to(equal(["Content-Type": "application/json"]))
            }

            it("returns body") {
                expect(try? self.subject.asURLRequest().httpBody).toNot(beNil())
            }
        }

    }

}
