//
//  AddExpenseVC.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 24/02/25.
//

import UIKit
protocol AddExpenseDelegate: AnyObject {
    func didAddExpense(_ expense: Expense)
}

class AddExpenseVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var expenseToEdit: Expense? {
        didSet {
            updateUIWithExpense()
        }
    }

    weak var delegate: AddExpenseDelegate?
    private let categories: [ExpenseCategory] = [.food, .transport, .shopping, .entertainment, .other]
    private var selectedCategory: ExpenseCategory?

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Expense Title"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Amount"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private let categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select Category"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Expense", for: .normal)
        button.addTarget(self, action: #selector(saveExpenseTapped), for: .touchUpInside)
        button.isEnabled = false // Disabled initially
        button.alpha = 0.5
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()

        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryTextField.inputView = categoryPicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        categoryTextField.inputAccessoryView = toolbar

        // Track all changes
        titleTextField.addTarget(self, action: #selector(userMadeChange), for: .editingChanged)
        amountTextField.addTarget(self, action: #selector(userMadeChange), for: .editingChanged)
        categoryTextField.addTarget(self, action: #selector(userMadeChange), for: .editingDidEnd)

        updateUIWithExpense()
    }
    
    @objc private func saveExpenseTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let amountText = amountTextField.text, let amount = Double(amountText),
              let category = selectedCategory else {
            print("Invalid input")
            return
        }
        
        if var existingExpense = expenseToEdit {
            // Editing existing expense
            existingExpense.title = title
            existingExpense.amount = amount
            existingExpense.category = category
            delegate?.didAddExpense(existingExpense)
        } else {
            // Creating new expense
            let newExpense = Expense(id: UUID(), title: title, amount: amount, category: category, date: Date())
            delegate?.didAddExpense(newExpense)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func userMadeChange() {
        saveButton.isEnabled = true // Enable button immediately
        saveButton.alpha = 1.0
        updateSaveButtonVisibility() // Ensure amount is valid before saving
    }
    
    @objc private func dismissPicker() {
        categoryTextField.resignFirstResponder()
    }
    
    private func updateUIWithExpense() {
        guard let expense = expenseToEdit else { return }
        
        titleTextField.text = expense.title
        amountTextField.text = "\(expense.amount)"
        categoryTextField.text = expense.category.rawValue
        selectedCategory = expense.category
    }
    
    private func updateSaveButtonVisibility() {
        let isAmountValid = (amountTextField.text?.isEmpty == false && Double(amountTextField.text!) != nil)
        
        if !isAmountValid {
            saveButton.isEnabled = false
            saveButton.alpha = 0.5 // Dimmed if amount is invalid
        }
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [titleTextField, amountTextField, categoryTextField, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
        categoryTextField.text = selectedCategory?.rawValue
        dismissPicker() // Close picker
        userMadeChange() // Ensure save button updates
    }
}
