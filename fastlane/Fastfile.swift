// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
	func buildLane() {
		desc("Build only")
  		buildIosApp(workspace: "in-ios.xcworkspace", scheme: "in-ios", configuration: "release", codesigningIdentity: "match AppStore com.innodemneurosciences.in-ios" )
	}

	func betaLane() {
		desc("Push a new beta build to TestFlight")
          buildIosApp(workspace: "in-ios.xcworkspace", scheme: "in-ios", configuration: "Release" )
	}
}
