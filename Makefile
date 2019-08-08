MACOS_XCODEFLAGS=-project Ribbon.xcodeproj -scheme 'Demo (macOS)' -destination 'platform=macOS'
IOS_XCODEFLAGS=-project Ribbon.xcodeproj -scheme 'Demo (iOS)' -destination 'platform=iOS Simulator,name=iPhone 8'
TEST_RESULTS_DIR=.testResults

.PHONY: all build build-ios build-macos test test-ios test-macos travis-test clean-test

all: build

build: build-ios build-macos

build-ios:
	xcodebuild $(IOS_XCODEFLAGS) -configuration Release | xcpretty && exit ${PIPESTATUS[0]}

build-macos:
	xcodebuild $(MACOS_XCODEFLAGS) -configuration Release | xcpretty && exit ${PIPESTATUS[0]}

test: test-ios test-macos

test-ios: clean-test
	xcodebuild test $(IOS_XCODEFLAGS) -configuration Debug -resultBundlePath $(TEST_RESULTS_DIR) | xcpretty && exit ${PIPESTATUS[0]}

test-macos:
	xcodebuild test $(MACOS_XCODEFLAGS) -configuration Debug | xcpretty && exit ${PIPESTATUS[0]}

travis-test: test
	./xccov-to-sonarqube-generic.sh $(TEST_RESULTS_DIR)/1_Test/action.xccovarchive/ > $(TEST_RESULTS_DIR)/sonarqube-generic-coverage.xml

clean-test:
	rm -rf .testResults
