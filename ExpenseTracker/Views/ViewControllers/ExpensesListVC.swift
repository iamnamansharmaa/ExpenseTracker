//
//  ExpensesListVC.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 24/02/25.
//

import UIKit
protocol DashboardVCDelegate: AnyObject { // Update Expenses on DashboardVC Controller
    func updateExpense(_ expense: Expense)
    func didDeleteExpense(_ expense: Expense)
}

class ExpensesListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var dashboardVCDelegate: DashboardVCDelegate?
    
    var expenses: [Expense] = [] {
        didSet {
            tableView.reloadData() // Refresh list when expenses update
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Expenses"
        
        // Instruction Label
        let instructionLabel = UILabel()
        instructionLabel.text = "Swipe left to delete an expense"
        instructionLabel.textColor = .darkGray
        instructionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        // Add TableView
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let expense = expenses[indexPath.row]
        cell.textLabel?.text = "\(expense.title) - ₹\(expense.amount) (\(expense.category.rawValue))"
        cell.textLabel?.textColor = expense.isEditable ? .black : .gray // Gray if editing is disabled
        return cell
    }

    // MARK: - UITableView Delegate (Editing)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expense = expenses[indexPath.row]
        guard expense.isEditable else {
            showAlert("Editing is disabled for expenses older than 4 days.")
            return
        }
        
        let editVC = AddExpenseVC()
        editVC.delegate = self
        editVC.expenseToEdit = expense // Pass the selected expense for editing
        navigationController?.pushViewController(editVC, animated: true)
    }

    // MARK: - Swipe to Delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            let expense = self.expenses[indexPath.row]
            self.confirmDelete(expense, at: indexPath)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Confirm Delete Alert
    private func confirmDelete(_ expense: Expense, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Expense?", message: "This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteExpense(expense, at: indexPath)
        }))
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Delete Expense
    private func deleteExpense(_ expense: Expense, at indexPath: IndexPath) {
        // Remove from local array
        expenses.remove(at: indexPath.row)
        
        // Notify DashboardVC
        dashboardVCDelegate?.didDeleteExpense(expense)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Delegate to Handle Expense Editing
extension ExpensesListVC: AddExpenseDelegate {
    func didAddExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense // Update existing expense
        } else {
            expenses.append(expense) // Add new expense
        }
        
        // Update Dashboard Controller
        dashboardVCDelegate?.updateExpense(expense)
    }
}
