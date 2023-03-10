import Foundation
@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift

final class MessageThreadCellViewModelTests: TestCase {
  fileprivate let vm: MessageThreadCellViewModelType = MessageThreadCellViewModel()

  fileprivate let date = TestObserver<String, Never>()
  fileprivate let dateAccessibilityLabel = TestObserver<String, Never>()
  fileprivate let messageBody = TestObserver<String, Never>()
  fileprivate let participantAvatarURL = TestObserver<URL?, Never>()
  fileprivate let participantName = TestObserver<String, Never>()
  fileprivate let projectName = TestObserver<String, Never>()
  fileprivate let replyIndicatorHidden = TestObserver<Bool, Never>()
  fileprivate let unreadIndicatorHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.date.observe(self.date.observer)
    self.vm.outputs.dateAccessibilityLabel.observe(self.dateAccessibilityLabel.observer)
    self.vm.outputs.messageBody.observe(self.messageBody.observer)
    self.vm.outputs.participantAvatarURL.observe(self.participantAvatarURL.observer)
    self.vm.outputs.participantName.observe(self.participantName.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.replyIndicatorHidden.observe(self.replyIndicatorHidden.observer)
    self.vm.outputs.unreadIndicatorHidden.observe(self.unreadIndicatorHidden.observer)
  }

  func testOutputs() {
    let thread = MessageThread.template
    self.vm.inputs.configureWith(messageThread: thread)

    self.date.assertValueCount(1)
    self.dateAccessibilityLabel.assertValueCount(1)
    self.messageBody.assertValues([thread.lastMessage.body])
    self.participantAvatarURL.assertValueCount(1)
    self.participantName.assertValues([thread.participant.name])
    self.projectName.assertValues([thread.project.name])
    self.unreadIndicatorHidden.assertValues([false])
  }

  func testReplyIndicatorHidden() {
    let thread = MessageThread.template

    self.vm.inputs.configureWith(messageThread: thread)
    self.replyIndicatorHidden.assertValues([true])

    withEnvironment(currentUser: thread.lastMessage.sender) {
      self.vm.inputs.configureWith(messageThread: thread)

      self.replyIndicatorHidden.assertValues([true, false])
    }
  }

  func testUnreadIndicatorHidden() {
    let thread = .template |> MessageThread.lens.unreadMessagesCount .~ 1

    self.vm.inputs.configureWith(messageThread: thread)

    self.unreadIndicatorHidden.assertValues([false])

    self.vm.inputs.setSelected(true)
    self.unreadIndicatorHidden.assertValues([false, true])

    self.vm.inputs.setSelected(false)
    self.unreadIndicatorHidden.assertValues([false, true])

    let newThread = .template
      |> MessageThread.lens.unreadMessagesCount .~ 3
      |> MessageThread.lens.id .~ (thread.id + 1)

    self.vm.inputs.configureWith(messageThread: newThread)
    self.unreadIndicatorHidden.assertValues([false, true, false])

    self.vm.inputs.configureWith(messageThread: thread)
    self.unreadIndicatorHidden.assertValues([false, true, false, true])
  }
}
