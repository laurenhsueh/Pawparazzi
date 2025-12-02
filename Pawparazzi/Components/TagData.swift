//
//  TagData.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//

import Foundation

struct TagData {
    
    /// Default categorized tags
    static let categorizedTags: [String: [String]] = [
        "Breed": ["Siamese", "Persian", "Maine Coon", "Bengal", "Ragdoll", "Sphynx"],
        "Color": ["Black", "White", "Gray", "Orange", "Spotted"],
        "Status": ["Overfed", "Needs Medical", "Healthy", "Shy"],
        "Personality": ["Playful", "Curious", "Friendly", "Calm", "Sleepy"]
    ]
    
    /// Quick recommended tags
    static let quickTags: [String] = ["Playful", "Overfed", "Needs Medical"]
}
