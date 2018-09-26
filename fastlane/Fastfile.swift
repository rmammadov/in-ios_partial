// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//
import Foundation

class Fastfile: LaneFile {
    func betaLane( withOptions options:[String: String]? )
    {
        desc( "Push a new beta build to TestFlight" )

        if let unit_tests = options?["unit_tests"], unit_tests == "true"
        {
            // execute unit tests here
        }

        buildIosApp( workspace: "in-ios.xcworkspace", scheme: "in-ios", configuration: "Release" )

        if let test_flight = options?["test_flight"], test_flight == "true"
        {
            uploadToTestflight( username: "dev@innodemneurosciences.com" )
        }
    }
}
