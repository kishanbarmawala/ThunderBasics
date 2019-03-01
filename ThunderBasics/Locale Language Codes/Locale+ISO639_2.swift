//
//  Locale+ISO639_2.swift
//  ThunderBasics
//
//  Created by Ryan Bourne on 04/02/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

extension Locale {
    
    /// An enum representation of available language formats
    ///
    /// - ISO639_1: ISO639-1 spec (e.g: "en", "es", "de")
    /// - ISO639_2: ISO638-2 spec (e.g: "eng", "spa", "deu")
    public enum LanguageFormat: String {
        case ISO639_1 = "ISO 639-1"
        case ISO639_2 = "ISO 639-2"
    }
    
    /// An enum representation of available region formats
    ///
    /// - ISO3166_1_alpha_2: ISO3166-1 alpha-2 spec (e.g: "GB", "US", "ES")
    /// - ISO3166_1_alpha_3: ISO3166-1 alpha-3 spec (e.g: "GBR", "USA", "ESP")
    /// - ISO3166_1_numeric: ISO3166-1 numeric spec (e.g: "826", "840", "724")
    public enum RegionFormat: String {
        case ISO3166_1_alpha_2 = "ISO 3166-1 alpha-2"
        case ISO3166_1_alpha_3 = "ISO 3166-1 alpha-3"
        case ISO3166_1_numeric = "ISO 3166-1 numeric"
    }
    
    /// Converts the locale to the specified formats
    ///
    /// - Parameters:
    ///   - languageFormat: The language format to use when converting
    ///   - regionFormat: The region format to use when converting
    ///
    /// - Note: If the language or region isn't convertable to the given format for any reason then it will be left as is on the original `Locale`
    /// - Returns: The converted locale.
    public func convertedTo(languageFormat: LanguageFormat, regionFormat: RegionFormat) -> Locale {
        
    }
    
    /// Provides the mapping from ISO639-1 to ISO639-2 language codes, so Locale language codes can be converted.
    public static var iso639_2Dictionary: [String: String]? = {
        guard let bundleURL = Bundle(identifier: "com.threesidedcube.ThunderBasics")?.url(forResource: "iso639_2", withExtension: "bundle") else {
            return nil
        }
        
        guard let plistURL = Bundle(url: bundleURL)?.url(forResource: "iso639_1_to_iso639_2", withExtension: "plist") else {
            return nil
        }
        
        guard let plistContents = try? PropertyListDecoder().decode([String: String].self, from: Data(contentsOf: plistURL)) else {
            return nil
        }
        
        return plistContents
    }()
    
    /// Determines the ISO639-2 language code for the locale.
    ///
    /// - Parameter mapping: The mapping dictionary that should be used. This should only be overriden from the default while in testing.
    /// - Returns: The ISO639-2 language code, if one is available.
    /// - Throws: An ISO639_2_Error, if the language code is unavailable.
    public func iso639_2_languageCode(from mapping: [String: String]? = Locale.iso639_2Dictionary) throws -> String {
        guard let iso639_1_languageCode = self.languageCode else {
            throw ISO639_2_Error.NoBaseLanguageCode
        }
        
        guard let iso639_2_languageCode = mapping?[iso639_1_languageCode] else {
            throw ISO639_2_Error.NoMatchingLanguageCode
        }
        
        return iso639_2_languageCode
    }
    
}
