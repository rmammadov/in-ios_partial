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
        println(message: "--- executing the buildlane ---")
  		buildIosApp(workspace: "in-ios.xcworkspace", scheme: "in-ios" )
	}

	func betaLane() {
		desc("Push a new beta build to TestFlight")
		syncCodeSigning(gitUrl: "git@github.com:innodem-neurosciences/code-signing.git", appIdentifier: ["com.innodemneurosciences.in-ios"], username: "dev@innodemneurosciences.com")
		buildIosApp(workspace: "in-ios.xcworkspace", scheme: "in-ios")
		uploadToTestflight(username: "dev@innodemneurosciences.com")
	}
}
