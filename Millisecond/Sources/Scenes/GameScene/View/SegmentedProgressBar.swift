//
//  SegmentedProgressBar.swift
//  Millisecond
//
//  Created by RAFA on 9/23/24.
//

import UIKit
import SnapKit

final class SegmentedProgressBar: UIView {

    // MARK: - Properties

    private let numberOfSegments: Int
    private var segmentViews: [UIView] = []
    private var fillViews: [UIView] = []

    // MARK: - Initializer

    init(numberOfSegments: Int) {
        self.numberOfSegments = numberOfSegments
        super.init(frame: .zero)

        configureUI()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    func updateProgress(segmentIndex: Int, progress: Float) {
        guard segmentIndex < fillViews.count else { return }

        UIView.animate(withDuration: 0.3) {
            self.updateFillWidths(segmentIndex: segmentIndex, progress: progress)
            self.layoutIfNeeded()
        }
    }

    func resetProgressWithoutAnimation() {
        UIView.performWithoutAnimation {
            fillViews.forEach { fillView in
                fillView.snp.updateConstraints {
                    $0.width.equalTo(0)
                }
            }
            layoutIfNeeded()
        }
    }

    // MARK: - UI

    private func configureUI() {
        for _ in 0..<numberOfSegments {
            let segment = createSegmentView()
            let fillView = createFillView()

            segmentViews.append(segment)
            fillViews.append(fillView)

            addSubview(segment)
            segment.addSubview(fillView)
        }
    }

    private func setConstraints() {
        let segmentWidth = calculateSegmentWidth()

        for (index, segment) in segmentViews.enumerated() {
            segment.snp.makeConstraints {
                $0.width.equalTo(segmentWidth)
                $0.height.equalTo(6)
                $0.left.equalToSuperview().offset(CGFloat(index) * (segmentWidth + 10))
                $0.centerY.equalToSuperview()
            }
        }

        fillViews.forEach { fillView in
            fillView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview()
                $0.height.equalTo(6)
                $0.width.equalTo(0)
            }
        }
    }
}

// MARK: - Private Helpers

private extension SegmentedProgressBar {

    func calculateSegmentWidth() -> CGFloat {
        let totalSpacing = 10 * CGFloat(numberOfSegments - 1)
        return (UIScreen.main.bounds.width - 32 - totalSpacing) / CGFloat(numberOfSegments)
    }

    func createSegmentView() -> UIView {
        let segment = UIView()
        segment.layer.cornerRadius = 2
        segment.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        return segment
    }

    func createFillView() -> UIView {
        let fillView = UIView()
        fillView.layer.cornerRadius = 2
        fillView.backgroundColor = .systemIndigo
        fillView.clipsToBounds = true
        return fillView
    }

    func updateFillWidths(segmentIndex: Int, progress: Float) {
        for (index, fillView) in fillViews.enumerated() {
            fillView.snp.updateConstraints {
                if index < segmentIndex {
                    $0.width.equalTo(segmentViews[index].frame.width)
                } else if index == segmentIndex {
                    $0.width.equalTo(segmentViews[index].frame.width * CGFloat(progress))
                } else {
                    $0.width.equalTo(0)
                }
            }
        }
    }
}
