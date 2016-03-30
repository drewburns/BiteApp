//
//  TextBite+CoreDataProperties.swift
//  Bite
//
//  Created by Andrew Burns on 1/16/16.
//  Copyright © 2016 Andrew Burns. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TextBite {

    @NSManaged var text: String?
    @NSManaged var name: String?

}
