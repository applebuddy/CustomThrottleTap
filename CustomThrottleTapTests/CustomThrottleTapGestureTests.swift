//
//  CustomThrottleTapGestureTests.swift
//  CustomThrottleTapGestureTests
//
//  Created by Min Min on 1/28/24.
//

@testable import CustomThrottleTapTest
import Combine
import UIKit
import XCTest

final class CustomThrottleTapGestureTests: XCTestCase {
  private let view = UIView()
  private var tapEventCount = 0
  private let defaultInterval: RunLoop.SchedulerTimeType.Stride = .milliseconds(300)
  private var throttleTapGestureCancellable: AnyCancellable?
  private let tapGestureRecognizer = UITapGestureRecognizer()

  override func setUp() {
    super.setUp()
    tapEventCount = 0
    throttleTapGestureCancellable = view
      .customThrottleTapGesture(
        gestureRecognizer: tapGestureRecognizer,
        for: defaultInterval
      )
      .sink { [weak self] _ in
        self?.tapEventCount += 1
      }
  }

  func testViewThrottleSingleTapGesture() {
    let expectation = XCTestExpectation(description: "trottle tap gesture event 1번 발생")
    let throttleTimeInterval = defaultInterval.timeInterval

    tapGestureRecognizer.state = .ended

    DispatchQueue.main.asyncAfter(
      deadline: .now() + throttleTimeInterval - 0.1
    ) { [weak self] in
      self?.tapGestureRecognizer.state = .ended
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + throttleTimeInterval + 0.1) {
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(tapEventCount, 1)
  }

  func testViewThrottleDoubleTapGesture() {
    let expectation = XCTestExpectation(description: "trottle tap gesture event 2번 발생")
    let throttleTimeInterval = defaultInterval.timeInterval

    tapGestureRecognizer.state = .ended

    DispatchQueue.main.asyncAfter(
      deadline: .now() + throttleTimeInterval - 0.1
    ) { [weak self] in
      self?.tapGestureRecognizer.state = .ended
    }

    DispatchQueue.main.asyncAfter(
      deadline: .now() + throttleTimeInterval + 0.1
    ) { [weak self] in
      self?.tapGestureRecognizer.state = .ended
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + throttleTimeInterval + 0.2) {
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: throttleTimeInterval + 0.3)

    XCTAssertEqual(tapEventCount, 2)
  }
}
