//
//  AudioParser.swift
//  r2-streamer-swift
//
//  Created by Mickaël Menu on 15/07/2020.
//
//  Copyright 2020 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

import Foundation
import R2Shared

/// Parses an audiobook Publication from an unstructured archive format containing audio files,
/// such as ZAB (Zipped Audio Book) or a simple ZIP.
///
/// It can also work for a standalone audio file.
public final class AudioParser: PublicationParser {
    
    public init() {}
    
    public func parse(file: File, fetcher: Fetcher, fallbackTitle: String, warnings: WarningLogger?) throws -> Publication.Components? {
        guard accepts(file, fetcher) else {
            return nil
        }
        
        let readingOrder = fetcher.links
            .filter { !ignores($0) && $0.mediaType?.isAudio == true }
            .sorted { $0.href.localizedCaseInsensitiveCompare($1.href) == .orderedAscending }
        
        guard !readingOrder.isEmpty else {
            return nil
        }
        
        return Publication.Components(
            fileFormat: .zab,
            publicationFormat: .cbz,
            manifest: Manifest(
                metadata: Metadata(
                    title: fetcher.guessTitle(ignoring: ignores) ?? fallbackTitle
                ),
                readingOrder: readingOrder
            ),
            fetcher: fetcher
        )
    }
    
    private func accepts(_ file: File, _ fetcher: Fetcher) -> Bool {
        if file.format == .zab {
            return true
        }
        
        // Checks if the fetcher contains only bitmap-based resources.
        return !fetcher.links.isEmpty
            && fetcher.links.allSatisfy { ignores($0) || $0.mediaType?.isAudio == true }
    }
    
    private func ignores(_ link: Link) -> Bool {
        let url = URL(fileURLWithPath: link.href)
        let filename = url.lastPathComponent
        let allowedExtensions = ["asx", "bio", "m3u", "m3u8", "pla", "pls", "smil", "txt", "vlc", "wpl", "xspf", "zpl"]
        
        return allowedExtensions.contains(url.pathExtension.lowercased())
            || filename.hasPrefix(".")
            || filename == "Thumbs.db"
    }
    
    @available(*, deprecated, message: "Not supported for `AudioParser`")
    public static func parse(at url: URL) throws -> (PubBox, PubParsingCallback) {
        fatalError("Not supported for `AudioParser`")
    }
    
}