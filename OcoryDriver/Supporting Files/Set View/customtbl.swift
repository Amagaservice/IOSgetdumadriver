//
//  customtbl.swift
//  OcoryDriver
//
//  Created by nile on 14/06/22.
//

import Foundation
import UIKit



class SelfSizingTableView: UITableView {
    var maxHeight = CGFloat.infinity

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = min(maxHeight, contentSize.height)
        return CGSize(width: contentSize.width, height: height)
    }
}
