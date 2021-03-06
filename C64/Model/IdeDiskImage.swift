/*
 IdeDiskDrive.swift -- Information about IDE Disk Drives
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

import Foundation
import C64UIComponents

struct IdeDiskImage {
    enum IdeType {
        case cd
        case compactFlash
        case hardDisk
        
        init?(pathExtension: String) {
            switch pathExtension {
            case "cfa":
                self = .compactFlash
            case "hdd":
                self = .hardDisk
            case "iso":
                self = .cd
            default:
                return nil
            }
        }
    }
    
    var ideType: IdeType
    var url: URL?
    var size: Int
    
    init?(url: URL) {
        guard let ideType = IdeType(pathExtension: url.pathExtension) else { return nil }
        
        self.ideType = ideType
        self.url = url
        do {
            let values = try url.resourceValues(forKeys: [.fileSizeKey])
            guard let size = values.fileSize else { return nil }
            self.size = size
        }
        catch {
            return nil
        }
    }
}

extension IdeDiskImage: MediaItem {
    var displayTitle: String? {
        return url?.lastPathComponent
    }
    
    var displaySubtitle: String? {
        if size > 1024 * 1024 * 1024 {
            let value = Int((Double(size) / (1024 * 1024 * 1024)).rounded(.up))
            return "\(value)gb"
        }
        else {
            let value = Int((Double(size) / (1024 * 1024)).rounded(.up))
            return "\(value)mb"
        }
    }
    
    var subtitleIsPETASCII: Bool {
        return false
    }
    
    var displayIcon: UIImage? {
        switch ideType {
        case .cd:
            return UIImage(named: "Compact Disc")
            
        case .compactFlash:
            return UIImage(named: "Compact Flash Card")
            
        case .hardDisk:
            return UIImage(named: "IDE Hard Disk")
        }
    }
}
