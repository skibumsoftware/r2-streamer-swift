//
//  EncryptionParserTests.swift
//  R2StreamerTests
//
//  Created by Mickaël Menu on 21.05.19.
//
//  Copyright 2019 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

import XCTest
import R2Shared
@testable import R2Streamer


class EncryptionParserTests: XCTestCase {
    
    func testParseLCPEncryption() {
        let parser = parseEncryption("encryption-lcp", drm: DRM(brand: .lcp))
        let sut = parser.encryptions

        XCTAssertEqual(sut, [
            "/chapter01.xhtml": EPUBEncryption(
                algorithm: "http://www.w3.org/2001/04/xmlenc#aes256-cbc",
                compression: "deflate",
                originalLength: 13291,
                profile: nil,
                scheme: "http://readium.org/2014/01/lcp"
            ),
            "/dir/chapter02.xhtml": EPUBEncryption(
                algorithm: "http://www.w3.org/2001/04/xmlenc#aes256-cbc",
                compression: "none",
                originalLength: 12914,
                profile: nil,
                scheme: "http://readium.org/2014/01/lcp"
            ),
        ])
    }
    
    func testParseEncryptionWithNamespaces() {
        let parser = parseEncryption("encryption-lcp-namespaces", drm: DRM(brand: .lcp))
        let sut = parser.encryptions

        XCTAssertEqual(sut, [
            "/chapter01.xhtml": EPUBEncryption(
                algorithm: "http://www.w3.org/2001/04/xmlenc#aes256-cbc",
                compression: "deflate",
                originalLength: 13291,
                profile: nil,
                scheme: "http://readium.org/2014/01/lcp"
            ),
            "/dir/chapter02.xhtml": EPUBEncryption(
                algorithm: "http://www.w3.org/2001/04/xmlenc#aes256-cbc",
                compression: "none",
                originalLength: 12914,
                profile: nil,
                scheme: "http://readium.org/2014/01/lcp"
            ),
        ])
    }
    
    func testParseEncryptionForUnknownDRM() {
        let parser = parseEncryption("encryption-unknown-drm")
        let sut = parser.encryptions
        
        XCTAssertEqual(sut, [
            "/html/chapter.html": EPUBEncryption(
                algorithm: "http://www.w3.org/2001/04/xmlenc#kw-aes128",
                compression: "deflate",
                originalLength: 12914,
                profile: nil,
                scheme: nil
            ),
            "/images/image.jpeg": EPUBEncryption(
                algorithm: "http://www.w3.org/2001/04/xmlenc#kw-aes128",
                compression: nil,
                originalLength: nil,
                profile: nil,
                scheme: nil
            ),
        ])
    }
    

    // MARK: - Toolkit
    
    func parseEncryption(_ name: String, drm: DRM? = nil) -> EncryptionParser {
        let url = SampleGenerator().getSamplesFileURL(named: "Encryption/\(name)", ofType: "xml")!
        let data = try! Data(contentsOf: url)
        return EncryptionParser(data: data, drm: drm)
    }
    
}
