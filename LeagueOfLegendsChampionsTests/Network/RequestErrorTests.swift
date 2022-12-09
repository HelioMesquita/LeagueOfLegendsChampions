import Quick
import Nimble

@testable import LeagueOfLegendsChampions

class RequestErrorTests: QuickSpec {

    override func spec() {
        super.spec()

        describe("#localizedDescription") {
            it("returns text from localizable strings") {
                expect(RequestError.badRequest.localizedDescription).to(equal(R.string.localizable.badRequest()))
            }
        }
    }

}
