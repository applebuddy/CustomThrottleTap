//
//  CustomThrottleTapTests.swift
//  CustomThrottleTapTestTests
//
//  Created by Min Min on 1/28/24.
//

@testable import CustomThrottleTapTest
import Combine
import UIKit
import XCTest

final class CustomThrottleTapTests: XCTestCase {
  private let button = UIButton()
  private var tapEventCount = 0
  private let defaultInterval: RunLoop.SchedulerTimeType.Stride = .milliseconds(300)
  private var throttleTapCancellable: AnyCancellable?

  override func setUp() {
    super.setUp()
    tapEventCount = 0
    throttleTapCancellable = button
      .customThrottleTap(for: defaultInterval)
      .sink { [weak self] _ in
        self?.tapEventCount += 1
      }
  }

  func testButtonThrottleSingleTap() {
    let expectation = XCTestExpectation(description: "trottle tap event 1번 발생")
    let throttleTimeInterval = defaultInterval.timeInterval

    button.sendActions(for: .touchUpInside)
    DispatchQueue.main.asyncAfter(
      deadline: .now() + throttleTimeInterval - 0.1
    ) { [weak self] in
      self?.button.sendActions(for: .touchUpInside)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + throttleTimeInterval + 0.1) {
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(tapEventCount, 1)
  }

  func testButtonThrottleDoubleTap() {
    let expectation = XCTestExpectation(description: "trottle tap event 2번 발생")
    let throttleTimeInterval = defaultInterval.timeInterval

    button.sendActions(for: .touchUpInside)

    DispatchQueue.main.asyncAfter(
      deadline: .now() + throttleTimeInterval - 0.1
    ) { [weak self] in
      self?.button.sendActions(for: .touchUpInside)
    }

    DispatchQueue.main.asyncAfter(
      deadline: .now() + throttleTimeInterval + 0.1
    ) { [weak self] in
      self?.button.sendActions(for: .touchUpInside)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + throttleTimeInterval + 0.2) {
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: throttleTimeInterval + 0.3)

    XCTAssertEqual(tapEventCount, 2)
  }
}

