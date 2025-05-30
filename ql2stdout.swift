#!/usr/bin/env swiftc -framework AppKit

import QuickLookThumbnailing
import AppKit

let args = CommandLine.arguments
guard args.count > 1 else {
    fputs("Usage: ql2stdout <file-path>\n", stderr)
    exit(1)
}

let request = QLThumbnailGenerator.Request(
    fileAt: URL(fileURLWithPath: args[1]),
    size: CGSize(width: 1024, height: 1024),
    scale: 1.0,
    representationTypes: .all
)

QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { (thumbnail, error) in
    if let error = error {
        fputs("Failed to generate thumbnail: \(error.localizedDescription)\n", stderr)
        exit(1)
    }

    guard let thumbnail = thumbnail,
          let tiffData = thumbnail.nsImage.tiffRepresentation else {
        fputs("Failed to convert thumbnail to TIFF.\n", stderr)
        exit(1)
    }

    FileHandle.standardOutput.write(tiffData)
    exit(0)
}

RunLoop.main.run()
