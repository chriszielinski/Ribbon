MACOS_XCODEFLAGS=-project Ribbon.xcodeproj -scheme 'Demo (macOS)' -destination 'platform=macOS'
IOS_XCODEFLAGS=-project Ribbon.xcodeproj -scheme 'Demo (iOS)' -destination 'platform=iOS Simulator,name=iPhone 8'
ENV_VARS=CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
TEST_RESULTS_DIR=./.testResults

.PHONY: all build build-ios build-macos test test-ios test-macos travis-test validate

all: build

build: build-ios build-macos

build-ios:
	xcodebuild $(IOS_XCODEFLAGS) -configuration Release $(ENV_VARS) | xcpretty && exit ${PIPESTATUS[0]}

build-macos:
	xcodebuild $(MACOS_XCODEFLAGS) -configuration Release $(ENV_VARS) | xcpretty && exit ${PIPESTATUS[0]}

test: test-ios test-macos

test-ios:
	rm -rf $(TEST_RESULTS_DIR)/iOS
	xcodebuild test $(IOS_XCODEFLAGS) -configuration Debug -resultBundlePath $(TEST_RESULTS_DIR)/iOS -enableCodeCoverage YES $(ENV_VARS) | xcpretty && exit ${PIPESTATUS[0]}

test-macos:
	rm -rf $(TEST_RESULTS_DIR)/macOS
	xcodebuild test $(MACOS_XCODEFLAGS) -configuration Debug -resultBundlePath $(TEST_RESULTS_DIR)/macOS -enableCodeCoverage YES $(ENV_VARS) | xcpretty && exit ${PIPESTATUS[0]}

travis-test: test-ios test-macos
	./Scripts/xccov-to-sonarqube-generic.sh $(TEST_RESULTS_DIR)/iOS/1_Test/action.xccovarchive/ $(TEST_RESULTS_DIR)/macOS/1_Test/action.xccovarchive/ > $(TEST_RESULTS_DIR)/sonarqube-generic-coverage.xml

validate:
	pod lib lint --allow-warnings
	carthage build --no-skip-current
	./Scripts/validate-carthage
