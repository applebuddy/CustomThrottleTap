//
//  Combine+Extension.swift
//  CustomThrottleTapTest
//
//  Created by Min Min on 1/28/24.
//

import Combine
import Foundation

extension Combine.Publisher where Self.Failure == Never {
  func customThrottle(
    for interval: RunLoop.SchedulerTimeType.Stride = .milliseconds(300)
  ) -> AnyPublisher<Self.Output, Never> {
    let initialEventState: (
      timeType: RunLoop.SchedulerTimeType?,
      output: Self.Output?
    ) = (nil, nil)

    return scan(initialEventState) { eventState, output in
      let eventTime = RunLoop.main.now

      guard let lastSentEventTime = eventState.timeType
      else {
        return (eventTime, output)
      }

      let eventTimeDifference = lastSentEventTime.distance(to: eventTime)
      guard eventTimeDifference >= interval
      else {
        return (lastSentEventTime, nil)
      }
      return (eventTime, output)
    }
    .compactMap(\.output)
    .eraseToAnyPublisher()
  }
}
