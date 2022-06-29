//
//  Joueur+CoreDataProperties.swift
//  Pendu_Labo2
//
//  Created by MAC on 2022-05-31.
//
//

import Foundation
import CoreData


extension Joueur {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Joueur> {
        return NSFetchRequest<Joueur>(entityName: "Joueur")
    }

    @NSManaged public var jeuId: Int16
    @NSManaged public var nom: String?
    @NSManaged public var stats: Int32

}

extension Joueur : Identifiable {

}
