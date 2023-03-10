import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public protocol DashboardReferrerRowStackViewViewModelInputs {
  /// Call to configure cell with referrer data.
  func configureWith(country: Project.Country, referrer: ProjectStatsEnvelope.ReferrerStats)
}

public protocol DashboardReferrerRowStackViewViewModelOutputs {
  /// Emits the number of backers to be displayed.
  var backersText: Signal<String, Never> { get }

  /// Emits the amount pledged and percentage to be displayed.
  var pledgedText: Signal<String, Never> { get }

  /// Emits the referrer source to be displayed.
  var sourceText: Signal<String, Never> { get }

  /// Emits the text color of the row labels to be displayed.
  var textColor: Signal<UIColor, Never> { get }
}

public protocol DashboardReferrerRowStackViewViewModelType {
  var inputs: DashboardReferrerRowStackViewViewModelInputs { get }
  var outputs: DashboardReferrerRowStackViewViewModelOutputs { get }
}

public final class DashboardReferrerRowStackViewViewModel: DashboardReferrerRowStackViewViewModelInputs,
  DashboardReferrerRowStackViewViewModelOutputs, DashboardReferrerRowStackViewViewModelType {
  public init() {
    let countryReferrer = self.countryReferrerProperty.signal.skipNil()

    self.backersText = countryReferrer.map { _, referrer in Format.wholeNumber(referrer.backersCount) }

    self.pledgedText = countryReferrer
      .map { country, referrer in
        Format.currency(Int(referrer.pledged), country: country) + " ("
          + Format.percentage(referrer.percentageOfDollars) + ")"
      }

    self.sourceText = countryReferrer.map { _, referrer in referrer.referrerName }

    self.textColor = countryReferrer.map { _, referrer in
      switch referrer.referrerType {
      case .internal:
        return .ksr_create_700
      case .external:
        return .ksr_celebrate_500
      default:
        return .ksr_trust_500
      }
    }
  }

  fileprivate let countryReferrerProperty =
    MutableProperty<(Project.Country, ProjectStatsEnvelope.ReferrerStats)?>(nil)
  public func configureWith(country: Project.Country, referrer: ProjectStatsEnvelope.ReferrerStats) {
    self.countryReferrerProperty.value = (country, referrer)
  }

  public let backersText: Signal<String, Never>
  public let pledgedText: Signal<String, Never>
  public let sourceText: Signal<String, Never>
  public let textColor: Signal<UIColor, Never>

  public var inputs: DashboardReferrerRowStackViewViewModelInputs { return self }
  public var outputs: DashboardReferrerRowStackViewViewModelOutputs { return self }
}
