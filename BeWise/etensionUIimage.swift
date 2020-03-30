//
//  etensionUIimage.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/10/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    func blurImage(){
        let blurEffe = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffeView = UIVisualEffectView(effect: blurEffe)
        blurEffeView.alpha = 0.92
        blurEffeView.frame = self.bounds
        
        blurEffeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffeView)
    }
}
