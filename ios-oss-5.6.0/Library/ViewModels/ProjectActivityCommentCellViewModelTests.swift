@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ProjectActivityCommentCellViewModelTests: TestCase {
  fileprivate let vm: ProjectActivityCommentCellViewModelType = ProjectActivityCommentCellViewModel()

  fileprivate let authorImage = TestObserver<String?, Never>()
  fileprivate let body = TestObserver<String, Never>()
  fileprivate let cellAccessibilityLabel = TestObserver<String, Never>()
  fileprivate let cellAccessibilityValue = TestObserver<String, Never>()
  fileprivate let defaultUser = User.template |> \.id .~ 9
  fileprivate let notifyDelegateGoToBacking = TestObserver<(Project, User), Never>()
  fileprivate let notifyDelegateGoToSendReply = TestObserver<(Project, Update?, ActivityComment), Never>()
  fileprivate let pledgeFooterIsHidden = TestObserver<Bool, Never>()
  fileprivate let title = TestObserver<String, Never>()

  private var sampleAuthor: ActivityCommentAuthor {
    ActivityCommentAuthor(
      avatar: .template,
      id: 1,
      name: "test",
      urls: .template
    )
  }

  private var sampleComment: ActivityComment {
    ActivityComment(
      author: self.sampleAuthor,
      body: "Love this project!",
      createdAt: .leastNonzeroMagnitude,
      deletedAt: nil,
      id: 1
    )
  }

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.authorImageURL.map { $0?.absoluteString }.observe(self.authorImage.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.cellAccessibilityValue.observe(self.cellAccessibilityValue.observer)
    self.vm.outputs.notifyDelegateGoToBacking.observe(self.notifyDelegateGoToBacking.observer)
    self.vm.outputs.notifyDelegateGoToSendReply
      .observe(self.notifyDelegateGoToSendReply.observer)
    self.vm.outputs.pledgeFooterIsHidden.observe(self.pledgeFooterIsHidden.observer)
    self.vm.outputs.title.observe(self.title.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: self.defaultUser))
  }

  func testAuthorImage() {
    let project = Project.template
    let user = User.template
      |> \.avatar.medium .~ "http://coolpic.com/cool.jpg"
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.authorImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits author's image URL")
  }

  func testBody() {
    let project = Project.template
    let body1 = "Thanks for the update!"

    let comment = ActivityComment(
      author: sampleAuthor,
      body: body1,
      createdAt: .leastNonzeroMagnitude,
      deletedAt: nil,
      id: 1
    )
    let commentPostActivity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.project .~ project
      |> Activity.lens.comment .~ comment

    self.vm.inputs.configureWith(activity: commentPostActivity, project: project)
    self.body.assertValues([body1], "Emits post comment's body")

    let body2 = "Aw, the limited bundle is all gone!"
    let comment2 = ActivityComment(
      author: sampleAuthor,
      body: body2,
      createdAt: .leastNonzeroMagnitude,
      deletedAt: nil,
      id: 1
    )

    let commentProjectActivity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ comment2
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: commentProjectActivity, project: project)
    self.body.assertValues([body1, body2], "Emits project comment's body")
  }

  func testCellAccessibilityLabel() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ self.sampleComment
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ (.template |> \.name .~ "Christopher")

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_user_name_commented_on_your_project(user_name: "Christopher")
      .htmlStripped() ?? ""
    self.cellAccessibilityLabel.assertValues([expected], "Should emit accessibility label")
  }

  func testCellAccessibilityValue() {
    let project = Project.template
    let body = "Thanks for the update!"
    let comment = ActivityComment(
      author: sampleAuthor,
      body: body,
      createdAt: .leastNonzeroMagnitude,
      deletedAt: nil,
      id: 1
    )
    let activity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ comment
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.cellAccessibilityValue.assertValues([body], "Emits accessibility value")
  }

  func testNotifyDelegateGoToBacking() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.project .~ project

    self.pledgeFooterIsHidden.assertValueCount(0)

    self.vm.inputs.configureWith(activity: activity, project: project)

    self.pledgeFooterIsHidden.assertValues([false], "Show the footer to go to pledge info.")

    self.vm.inputs.backingButtonPressed()
    self.notifyDelegateGoToBacking.assertValueCount(1, "Should go to backing")
  }

  func testNotifyDelegateGoToSendReply_Project() {
    let project = Project.template
    let user = User.template |> \.name .~ "Christopher"
    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ self.sampleComment
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.vm.inputs.replyButtonPressed()
    self.notifyDelegateGoToSendReply.assertValueCount(1, "Should go to send reply on project")
  }

  func testNotifyDelegateGoToSendReply_Update() {
    let project = Project.template
    let update = Update.template
    let user = User.template |> \.name .~ "Christopher"
    let activity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ self.sampleComment
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.vm.inputs.replyButtonPressed()
    self.notifyDelegateGoToSendReply.assertValueCount(1, "Should go to send reply on update")
  }

  func testTitleProject() {
    let project = Project.template

    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ self.sampleComment
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ (.template |> \.name .~ "Christopher")

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_user_name_commented_on_your_project(user_name: "Christopher")
    self.title.assertValues([expected], "Should emit that author commented on project")
  }

  func testTitleProjectAsCurrentUser() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ self.sampleComment
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ self.defaultUser

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_you_commented_on_your_project()
    self.title.assertValues([expected], "Should emit 'you' commented on project")
  }

  func testTitleUpdate() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ self.sampleComment
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ (.template |> Update.lens.sequence .~ 5)
      |> Activity.lens.user .~ (.template |> \.name .~ "Christopher")

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_user_name_commented_on_update_number(
      user_name: "Christopher",
      space: "\u{00a0}",
      update_number: "5"
    )
    self.title.assertValues([expected], "Should emit that author commented on update")
  }

  func testTitleUpdateAsCurrentUser() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ self.sampleComment
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ (.template |> Update.lens.sequence .~ 5)
      |> Activity.lens.user .~ self.defaultUser

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_you_commented_on_update_number(
      space: "\u{00a0}",
      update_number: "5"
    )
    self.title.assertValues([expected], "Should emit 'you' commented on update")
  }

  func testHideReplyAndPledgeInfoButtons_IfUserIsCreator() {
    let creator = User.template |> \.name .~ "Benny"
    let project = .template |> Project.lens.creator .~ creator
    let activity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ self.sampleComment
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ creator

    withEnvironment(currentUser: creator) {
      self.pledgeFooterIsHidden.assertValueCount(0)

      self.vm.inputs.configureWith(activity: activity, project: project)

      self.pledgeFooterIsHidden.assertValues([true], "Hide the footer for the creator.")
    }
  }
}
