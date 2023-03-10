@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class ProjectActivitiesViewModelTests: TestCase {
  fileprivate let vm: ProjectActivitiesViewModelType = ProjectActivitiesViewModel()

  fileprivate let activitiesPresent = TestObserver<Bool, Never>()
  fileprivate let goTo = TestObserver<ProjectActivitiesGoTo, Never>()
  fileprivate let groupedDates = TestObserver<Bool, Never>()
  fileprivate let isRefreshing = TestObserver<Bool, Never>()
  fileprivate let project = TestObserver<Project, Never>()
  fileprivate let showEmptyState = TestObserver<Bool, Never>()

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
      author: sampleAuthor,
      body: "Love this project!",
      createdAt: .leastNonzeroMagnitude,
      deletedAt: nil,
      id: 1
    )
  }

  override func setUp() {
    super.setUp()

    self.vm.outputs.projectActivityData
      .map { !$0.activities.isEmpty }
      .observe(self.activitiesPresent.observer)
    self.vm.outputs.goTo.observe(self.goTo.observer)
    self.vm.outputs.isRefreshing.observe(self.isRefreshing.observer)
    self.vm.outputs.projectActivityData
      .map { $0.project }
      .observe(self.project.observer)
    self.vm.outputs.projectActivityData
      .map { $0.groupedDates }
      .observe(self.groupedDates.observer)
    self.vm.outputs.showEmptyState.observe(self.showEmptyState.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
  }

  func testFlow() {
    let project = Project.template

    withEnvironment(apiService: MockService(
      fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 1]
    )) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.activitiesPresent.assertDidNotEmitValue("No activities")
      self.scheduler.advance()

      self.activitiesPresent.assertValues([true], "Show activities after scheduler advances")
      self.groupedDates.assertValues([true], "Group dates by default")
      self.project.assertValues([project], "Emits project")
    }

    withEnvironment(apiService: MockService(
      fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 2]
    )) {
      self.vm.inputs.refresh()
      self.scheduler.advance()

      self.activitiesPresent.assertValues([true, true], "Activities refreshed")
      self.groupedDates.assertValues([true, true], "Group dates by default")
      self.project.assertValues([project, project], "Emits project")
    }

    withEnvironment(apiService: MockService(
      fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 3]
    )) {
      self.vm.inputs.willDisplayRow(9, outOf: 10)
      self.scheduler.advance()

      self.activitiesPresent.assertValues([true, true, true], "Activities paginate")
      self.groupedDates.assertValues([true, true, true], "Group dates by default")
      self.project.assertValues([project, project, project], "Emits project")
    }

    self.showEmptyState.assertValues(
      [false],
      "Don't show, because each activity emission was a non-empty array"
    )
  }

  func testEmptyState() {
    let project = Project.template

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse: [])) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.activitiesPresent.assertValues([false], "No activities")
      self.showEmptyState.assertValues([true], "Activities not present, show empty state")
      self.project.assertValues([project], "Emits project")
    }
  }

  func testGoTo() {
    let backing = Backing.template |> Backing.lens.projectId .~ Project.template.id
    let project = Project.template |> Project.lens.personalization.backing .~ backing
    let comment = self.sampleComment
    let update = Update.template
    let user = User.template

    let backingActivity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ backing
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    let commentPostActivity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ comment
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update
      |> Activity.lens.user .~ user

    let commentProjectActivity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ comment
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    let successActivity = .template
      |> Activity.lens.category .~ .failure
      |> Activity.lens.project .~ (project |> Project.lens.state .~ .successful)
      |> Activity.lens.user .~ user

    let updateActivity = .template
      |> Activity.lens.category .~ .update
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update
      |> Activity.lens.user .~ user

    withEnvironment(apiService: MockService(
      fetchProjectActivitiesResponse:
      [backingActivity, commentPostActivity, commentProjectActivity, successActivity, updateActivity]
    )) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      // Testing when cells are tapped for different categories of activity

      self.vm.inputs.activityAndProjectCellTapped(activity: backingActivity, project: project)
      self.goTo.assertValueCount(1, "Should go to backing")

      self.vm.inputs.activityAndProjectCellTapped(activity: commentPostActivity, project: project)
      self.goTo.assertValueCount(2, "Should go to comments for update")

      self.vm.inputs.activityAndProjectCellTapped(activity: commentProjectActivity, project: project)
      self.goTo.assertValueCount(3, "Should go to comments for project")

      self.vm.inputs.activityAndProjectCellTapped(activity: successActivity, project: project)
      self.goTo.assertValueCount(4, "Should go to project")

      self.vm.inputs.activityAndProjectCellTapped(activity: updateActivity, project: project)
      self.goTo.assertValueCount(5, "Should go to update")

      // Testing delegate methods

      self.vm.inputs.projectActivityBackingCellGoToBacking(project: project, backing: backing)
      self.goTo.assertValueCount(6, "Should go to backing")

      self.vm.inputs.projectActivityBackingCellGoToSendMessage(project: project, backing: backing)
      self.goTo.assertValueCount(7, "Should go to send message")

      self.vm.inputs.projectActivityCommentCellGoToSendReply(project: project, update: nil, comment: comment)
      self.goTo.assertValueCount(8, "Should go to comments for project")

      self.vm.inputs.projectActivityCommentCellGoToSendReply(
        project: project,
        update: update,
        comment: comment
      )
      self.goTo.assertValueCount(9, "Should go to comments for update")

      withEnvironment(apiService: MockService(fetchBackingResponse: .template)) {
        self.vm.inputs.projectActivityCommentCellGoToBacking(project: project, user: user)

        self.scheduler.advance()

        self.goTo.assertValueCount(10, "Should go to backing after fetching backing")
      }
    }
  }

  func testGroupedDatesWhenVoiceOverIsNotRunning() {
    let project = Project.template
    let activities = [.template |> Activity.lens.project .~ project]

    withEnvironment(
      apiService: MockService(fetchProjectActivitiesResponse: activities),
      isVoiceOverRunning: { false }
    ) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()
      self.groupedDates.assertValues([true], "Group dates when VoiceOver is not running")
    }
  }

  func testGroupedDatesWhenVoiceOverIsRunning() {
    let project = Project.template
    let activities = [.template |> Activity.lens.project .~ project]

    withEnvironment(
      apiService: MockService(fetchProjectActivitiesResponse: activities),
      isVoiceOverRunning: { true }
    ) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()
      self.groupedDates.assertValues([false], "Don't group dates when VoiceOver is running")
    }
  }
}
