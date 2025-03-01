//
//  CoreDataManager.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 24/02/25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    private let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "ExpenseModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - CRUD Operations
    func saveExpense(_ expense: Expense) {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            
            if let existingExpense = results.first {
                // Update existing expense
                existingExpense.title = expense.title
                existingExpense.amount = expense.amount
                existingExpense.category = expense.category.rawValue
                existingExpense.date = expense.date
            } else {
                // Create new expense if not found
                let newExpense = ExpenseEntity(context: context)
                newExpense.id = expense.id
                newExpense.title = expense.title
                newExpense.amount = expense.amount
                newExpense.category = expense.category.rawValue
                newExpense.date = expense.date
            }
            
            saveContext() // Save changes to Core Data
        } catch {
            print("Failed to save/update expense: \(error)")
        }
    }

    func fetchExpenses() -> [Expense] {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let title = entity.title,
                      let category = entity.category,
                      let date = entity.date,
                      let categoryEnum = ExpenseCategory(rawValue: category)
                else { return nil }

                return Expense(id: id, title: title, amount: entity.amount, category: categoryEnum, date: date)
            }
        } catch {
            print("Failed to fetch expenses: \(error)")
            return []
        }
    }

    func deleteExpense(_ id: UUID) {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Failed to delete expense: \(error)")
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save Core Data: \(error)")
        }
    }
}
