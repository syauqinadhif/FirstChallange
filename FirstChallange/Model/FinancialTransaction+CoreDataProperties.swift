//
//  FinancialTransaction+CoreDataProperties.swift
//  FirstChallange
//
//  Created by Syauqi Ikhlasun Nadhif on 26/03/25.
//
//

import Foundation
import CoreData


extension FinancialTransaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialTransaction> {
        return NSFetchRequest<FinancialTransaction>(entityName: "FinancialTransaction")
    }

    @NSManaged public var amount: Int64
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isExpense: Bool
    @NSManaged public var notes: String?

}

extension FinancialTransaction : Identifiable {

}
