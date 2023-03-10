import Prelude
import Prelude_UIKit
import UIKit

public let projectActivityBulletSeparatorViewStyle: (UIView) -> UIView = { view in
  view
    |> roundedStyle(cornerRadius: 2.0)
    |> UIView.lens.backgroundColor .~ .ksr_support_400
}

public let projectActivityDividerViewStyle = UIView.lens.backgroundColor .~ .ksr_support_300

public let projectActivityFooterButton =
  UIButton.lens.titleColor(for: .normal) .~ .ksr_create_700
    <> UIButton.lens.titleLabel.font .~ UIFont.ksr_footnote(size: 12).bolded
    <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_support_100

public let projectActivityFooterStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
    <> UIStackView.lens.spacing .~ Styles.grid(2)

public let projectActivityHeaderStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(2))
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
    <> UIStackView.lens.spacing .~ Styles.grid(1)

public let projectActivityRegularRegularLeftRight = Styles.grid(30)

public let projectActivityRegularRegularLayoutMargins: UIEdgeInsets =
  .init(topBottom: Styles.grid(4), leftRight: projectActivityRegularRegularLeftRight)

// Use `.ksr_body` for font.
public let projectActivityStateChangeLabelStyle = UILabel.lens.numberOfLines .~ 0
  <> UILabel.lens.textAlignment .~ .center

// Use `.ksr_title3(size: 14)` for font.
public let projectActivityTitleLabelStyle = UILabel.lens.textColor .~ .ksr_support_700
  <> UILabel.lens.numberOfLines .~ 2
