//
//  UIView+Extension.swift
//  CustomThrottleTapTest
//
//  Created by Min Min on 1/28/24.
//

import Combine
import UIKit

extension UIView {
  func customThrottleTapGesture(
    gestureRecognizer: UITapGestureRecognizer = .init(),
    for interval: RunLoop.SchedulerTimeType.Stride = .milliseconds(300)
  ) -> AnyPublisher<UITapGestureRecognizer, Never> {
    UITapGestureRecognizer.GesturePublisher(
      recognizer: gestureRecognizer,
      view: self
    )
    .customThrottle(for: interval)
  }
}
