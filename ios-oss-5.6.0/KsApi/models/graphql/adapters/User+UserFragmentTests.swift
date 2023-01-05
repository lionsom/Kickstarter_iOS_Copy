import Foundation
@testable import KsApi
import XCTest

final class User_UserFragmentTests: XCTestCase {
  func testUserCreation_FromFragment_Success() {
    let userFragment = GraphAPI.UserFragment(unsafeResultMap: UserFragmentTemplate.valid.data)

    let user = User.user(from: userFragment)

    XCTAssertEqual(user?.id, 47)
    XCTAssertEqual(user?.avatar.large, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.avatar.medium, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.avatar.small, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.isCreator, true)
    XCTAssertEqual(user?.name, "Billy Bob")
    XCTAssertEqual(user?.erroredBackingsCount, 1)
    XCTAssertTrue(user!.facebookConnected!)
    XCTAssertTrue(user!.isFriend!)
    XCTAssertFalse(user!.isAdmin!)
    XCTAssertEqual(user!.location?.country, "US")
    XCTAssertEqual(user!.location?.displayableName, "Las Vegas, NV")
    XCTAssertEqual(user!.location?.name, "Las Vegas")
    XCTAssertEqual(user!.location?.id, decompose(id: "TG9jYXRpb24tMjQzNjcwNA=="))
    XCTAssertEqual(user!.unseenActivityCount, 1)
    XCTAssertTrue(user!.needsFreshFacebookToken!)
    XCTAssertTrue(user!.showPublicProfile!)
    XCTAssertTrue(user!.optedOutOfRecommendations!)
    XCTAssertEqual(user!.stats.backedProjectsCount!, 1)
    XCTAssertEqual(user!.stats.createdProjectsCount!, 16)
    XCTAssertNil(user!.stats.draftProjectsCount)
    XCTAssertNil(user!.stats.memberProjectsCount)
    XCTAssertEqual(user!.stats.starredProjectsCount!, 11)
    XCTAssertEqual(user!.stats.unansweredSurveysCount!, 2)
    XCTAssertEqual(user!.stats.unreadMessagesCount!, 0)
    XCTAssertTrue(user!.notifications.messages!)
    XCTAssertTrue(user!.notifications.mobileMessages!)
    XCTAssertFalse(user!.notifications.backings!)
    XCTAssertTrue(user!.notifications.mobileBackings!)
    XCTAssertTrue(user!.notifications.creatorDigest!)
    XCTAssertTrue(user!.notifications.updates!)
    XCTAssertTrue(user!.notifications.follower!)
    XCTAssertTrue(user!.notifications.mobileFollower!)
    XCTAssertTrue(user!.notifications.friendActivity!)
    XCTAssertFalse(user!.notifications.mobileFriendActivity!)
    XCTAssertTrue(user!.notifications.comments!)
    XCTAssertTrue(user!.notifications.mobileComments!)
    XCTAssertTrue(user!.notifications.commentReplies!)
    XCTAssertTrue(user!.notifications.mobileComments!)
    XCTAssertTrue(user!.notifications.creatorDigest!)
    XCTAssertFalse(user!.notifications.mobileMarketingUpdate!)
    XCTAssertTrue(user!.newsletters.arts!)
    XCTAssertFalse(user!.newsletters.films!)
    XCTAssertFalse(user!.newsletters.music!)
    XCTAssertFalse(user!.newsletters.invent!)
    XCTAssertFalse(user!.newsletters.games!)
    XCTAssertFalse(user!.newsletters.publishing!)
    XCTAssertFalse(user!.newsletters.promo!)
    XCTAssertFalse(user!.newsletters.weekly!)
    XCTAssertFalse(user!.newsletters.happening!)
    XCTAssertTrue(user!.newsletters.alumni!)
  }
}