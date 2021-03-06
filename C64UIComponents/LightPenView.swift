/*
 LightPenView.swift -- Virtual Light Pen
 Copyright (C) 2019 Dieter Baron
 
 This file is part of C64, a Commodore 64 emulator for iOS, based on VICE.
 The authors can be contacted at <c64@spiderlab.at>
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307  USA.
*/

import UIKit

public protocol LightPenViewDelegate {
    func lightPenView(_ sender: LightPenView, changed position: CGPoint?, size: CGSize, button1: Bool, button2: Bool)
}

public class LightPenView: UIView {
    @IBInspectable public var topOffset: CGFloat = 0

    public var delegate: LightPenViewDelegate?
    
    private var lightPenGestureRecoginzer: LightPenGestureRecognizer!
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        
        lightPenGestureRecoginzer = LightPenGestureRecognizer(target: self, action: #selector(lightPen(_:)))
        addGestureRecognizer(lightPenGestureRecoginzer)
    }
    
    @objc func lightPen(_ sender: LightPenGestureRecognizer) {
        var size = frame.size
        size.height += topOffset
        
        if let position = lightPenGestureRecoginzer.position {
            delegate?.lightPenView(self, changed: CGPoint(x: position.x, y: position.y + topOffset), size: size, button1: lightPenGestureRecoginzer.button1, button2: lightPenGestureRecoginzer.button2)
        }
        else {
            delegate?.lightPenView(self, changed: nil, size: size, button1: lightPenGestureRecoginzer.button1, button2: lightPenGestureRecoginzer.button2)
        }
    }
}
