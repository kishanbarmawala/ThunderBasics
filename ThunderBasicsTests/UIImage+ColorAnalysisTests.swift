//
//  UIImage+ColorAnalysisTests.swift
//  ThunderBasicsTests
//
//  Created by Simon Mitchell on 05/10/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderBasics

func imageNamed(_ imageName: String, withExtension fileExtension: String = "png") -> UIImage? {
    
    guard let imageURL = Bundle(for: UIImage_ColorAnalysisTests.self).url(forResource: imageName, withExtension: fileExtension) else {
        XCTFail("Failed to get test asset from bundle")
        return nil
    }
    guard let imageData = try? Data(contentsOf: imageURL) else {
        XCTFail("Failed to read data from \(imageURL)")
        return nil
    }
    
    return UIImage(data: imageData)
}

class UIImage_ColorAnalysisTests: XCTestCase {

    func testAlternativeColorSpaceIsAnalysedCorrectly() {
        
        guard let image = imageNamed("earthquake_badge") else {
            XCTFail("Failed to create image from data")
            return
        }
        
        let colorAnalyser = ImageColorAnalyzer(image: image)
        colorAnalyser.analyze()
        
        XCTAssertNotNil(colorAnalyser.primaryColor)
        XCTAssertEqual(colorAnalyser.backgroundColor, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0))
        XCTAssertEqual(colorAnalyser.primaryColor, UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0))
        XCTAssertEqual(colorAnalyser.secondaryColor?.isDistinctFrom(color: UIColor(red: 0.964706, green: 0.701961, blue: 0.156863, alpha: 1.0), threshold: 0.0001), false)
        XCTAssertEqual(colorAnalyser.detailColor?.isDistinctFrom(color: UIColor(red: 0.980392, green: 0.843137, blue: 0.537255, alpha: 1.0), threshold: 0.0001), false)
    }
    
    func testLeftEdgeOffsetIsRespected() {
        
        guard let image = imageNamed("earthquake_badge") else {
            XCTFail("Failed to create image from data")
            return
        }
        
        let colorAnalyser = ImageColorAnalyzer(image: image)
        colorAnalyser.analyze(pixelThreshold: 0, leftEdgeOffset: 5)
        
        XCTAssertNotNil(colorAnalyser.primaryColor)
        XCTAssertEqual(colorAnalyser.backgroundColor?.isDistinctFrom(color: UIColor(red: 0.960784, green: 0.65098, blue: 0.137255, alpha: 1.0), threshold: 0.0001), false)
        XCTAssertEqual(colorAnalyser.primaryColor?.isDistinctFrom(color: UIColor(red: 0.996078, green: 0.996078, blue: 0.846667, alpha: 1.0), threshold: 0.0001), false)
        XCTAssertNil(colorAnalyser.secondaryColor)
        XCTAssertNil(colorAnalyser.detailColor)
    }
    
    func testPixelThresholdIsRespected() {
        
        guard let image = imageNamed("earthquake_badge") else {
            XCTFail("Failed to create image from data")
            return
        }
        
        let colorAnalyser = ImageColorAnalyzer(image: image)
        colorAnalyser.analyze(pixelThreshold: 40, leftEdgeOffset: 0)
        
        XCTAssertNotNil(colorAnalyser.primaryColor)
        XCTAssertEqual(colorAnalyser.backgroundColor, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0))
        XCTAssertEqual(colorAnalyser.primaryColor, UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0))
        XCTAssertEqual(colorAnalyser.secondaryColor?.isDistinctFrom(color: UIColor(red: 0.964706, green: 0.701961, blue: 0.156863, alpha: 1.0), threshold: 0.0001), false)
        XCTAssertEqual(colorAnalyser.detailColor?.isDistinctFrom(color: UIColor(red: 0.980392, green: 0.843137, blue: 0.537255, alpha: 1.0), threshold: 0.0001), false)
    }
}
