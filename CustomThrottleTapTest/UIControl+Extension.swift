//
//  UIControl+Extension.swift
//  CustomThrottleTapTest
//
//  Created by Min Min on 1/28/24.
//

import Combine
import UIKit

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

extension UIControl {
  func customThrottleTap(
    for interval: RunLoop.SchedulerTimeType.Stride = .milliseconds(300)
  ) -> AnyPublisher<UIControl, Never> {
    return GesturePublisher(control: self, controlEvent: .touchUpInside)
      .customThrottle(for: interval)
  }
}

extension UIControl {
  struct GesturePublisher<Control: UIControl>: Publisher {
    typealias Output = Control
    typealias Failure = Never

    private let control: Control
    private let controlEvent: Control.Event

    init(control: Control, controlEvent: UIControl.Event) {
      self.control = control
      self.controlEvent = controlEvent
    }

    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Control == S.Input {
      let subscription = GestureSubscription(
        subscriber: subscriber,
        control: control,
        event: controlEvent
      )
      subscriber.receive(subscription: subscription)
    }
  }

  final class GestureSubscription<S: Subscriber, Control: UIControl>: Subscription
    where S.Input == Control {
    private var subscriber: S?
    private let control: Control

    init(subscriber: S? = nil, control: Control, event: UIControl.Event) {
      self.subscriber = subscriber
      self.control = control
      control.addAction(
        UIAction { [weak self] _ in
          self?.eventHandler()
        },
        for: event
      )
    }

    func request(_ demand: Subscribers.Demand) { }

    func cancel() {
      subscriber = nil
    }

    func eventHandler() {
      _ = subscriber?.receive(control)
    }
  }
}

