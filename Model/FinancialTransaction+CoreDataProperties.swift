//
//  FinancialTransaction+CoreDataProperties.swift
//  FirstChallange
//
//  Created by Syauqi Ikhlasun Nadhif on 20/03/25.
//
//

import Foundation
import CoreData


extension FinancialTransaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialTransaction> {
        return NSFetchRequest<FinancialTransaction>(entityName: "FinancialTransaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isExpense: Bool

}

extension FinancialTransaction : Identifiable {

}
