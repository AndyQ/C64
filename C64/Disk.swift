/*
 Disk.swift -- Core Data Entity Disk
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

import CoreData

public class Disk: NSManagedObject {
    // MARK: - CoreData properties
    
    @NSManaged var fileName: String
    
    @NSManaged var game: Game
    
    // MARK: - initializers
    
    convenience init(fileName: String, insertInto context: NSManagedObjectContext) {
        self.init(entity: Disk.entity(), insertInto: context)
        
        self.fileName = fileName
    }
    
    override public var description: String {
        return fileName
    }
}
