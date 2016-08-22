//
//  FTFont.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 10..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

enum FTFontType {
    case Regular, Bold, Light, Medium
}

extension UIFont {
    
    static func defaultFont(type: FTFontType, size: CGFloat) -> UIFont? {
        
        let baseFontName = "HelveticaNeue"
        
        var fontName: String?
        
        switch type {
        case .Bold: fontName = baseFontName + "-Bold"
        case .Medium: fontName = baseFontName + "-Medium"
        case .Light: fontName = baseFontName + "-Light"
        default: fontName = baseFontName
        }
        
        if fontName != nil {
            return UIFont(name: fontName!, size: size);
        }
        
        return nil;
    }
    
    static func printFonts() {
        
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName)
            print("Font Names = [\(names)]")
        }
        print("done")
    }
}

/*
 
 Font Family Name = [Helvetica Neue]
 Font Names = [["HelveticaNeue-Italic", "HelveticaNeue-Bold", "HelveticaNeue-UltraLight", "HelveticaNeue-CondensedBlack", "HelveticaNeue-BoldItalic", "HelveticaNeue-CondensedBold", "HelveticaNeue-Medium", "HelveticaNeue-Light", "HelveticaNeue-Thin", "HelveticaNeue-ThinItalic", "HelveticaNeue-LightItalic", "HelveticaNeue-UltraLightItalic", "HelveticaNeue-MediumItalic", "HelveticaNeue"]]
 
 */
