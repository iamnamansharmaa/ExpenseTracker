//
//  DashboardVC.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 24/02/25.
//

import UIKit
import DGCharts
class DashboardVC: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let tableView = UITableView()
    private let viewModel = ExpenseViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Expense Tracker"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    private let totalExpenseLabel: UILabel = {
        let label = UILabel()
        label.text = "Total: ₹0.00"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private let addExpenseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("➕ Add Expense", for: .normal)
        button.addTarget(self, action: #selector(addExpenseTapped), for: .touchUpInside)
        return button
    }()
    
    private let viewExpensesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📜 View Expenses", for: .normal)
        button.addTarget(self, action: #selector(openExpenseList), for: .touchUpInside)
        return button
    }()
    
    private let pieChartView: PieChartView = {
        let chart = PieChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    private let barChartView: BarChartView = {
         let chart = BarChartView()
         chart.translatesAutoresizingMaskIntoConstraints = false
         return chart
     }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupLayout()
        fetchExpensesFromBackend()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func fetchExpensesFromBackend() {
        // Fetching Data From Backend
        ExpenseSyncManager.shared.fetchExpensesFromBackend() { response in
            if response {
                self.viewModel.loadExpenses()
                self.reloadData()
            } else {
                self.reloadData()
                print("Error Fething Data From Backend")
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        
        [titleLabel, totalExpenseLabel, pieChartView, barChartView, addExpenseButton, viewExpensesButton, tableView].forEach {
            stackView.addArrangedSubview($0)
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.identifier)
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            pieChartView.widthAnchor.constraint(equalToConstant: 300),
            pieChartView.heightAnchor.constraint(equalToConstant: 300),
            
            barChartView.widthAnchor.constraint(equalToConstant: 300),
            barChartView.heightAnchor.constraint(equalToConstant: 300),
            
            tableView.heightAnchor.constraint(equalToConstant: 300),
            tableView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }

    @objc private func addExpenseTapped() {
        let addExpenseVC = AddExpenseVC()
        addExpenseVC.delegate = self
        navigationController?.pushViewController(addExpenseVC, animated: true)
    }
    
    @objc private func openExpenseList() {
        let expenseListVC = ExpensesListVC()
        expenseListVC.dashboardVCDelegate = self
        expenseListVC.expenses = viewModel.getExpenses()
        navigationController?.pushViewController(expenseListVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension DashboardVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getExpenses().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifier, for: indexPath) as? ExpenseTableViewCell else {
            return UITableViewCell()
        }
        let expense = viewModel.getExpenses()[indexPath.row]
        cell.configure(with: expense)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension DashboardVC {
    func updateCharts() {
        if viewModel.expenses.isEmpty {
            pieChartView.isHidden = true
            barChartView.isHidden = true
            return
        }
        
        pieChartView.isHidden = false
        barChartView.isHidden = false
        
        updateBarChartData()
        updateChartData()
    }
    
    private func updateBarChartData() {
        var monthTotals: [String: Double] = [:]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        for expense in viewModel.expenses {
            let month = formatter.string(from: expense.date)
            monthTotals[month, default: 0] += expense.amount
        }
        
        let entries = monthTotals.enumerated().map { index, element in
            return BarChartDataEntry(x: Double(index), y: element.value)
        }
        
        let dataSet = BarChartDataSet(entries: entries, label: "Monthly Expenses")
        dataSet.colors = [UIColor.systemBlue]
        
        let data = BarChartData(dataSet: dataSet)
        barChartView.data = data
    }
    
    private func updateChartData() {
        var monthTotals: [String: Double] = [:]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        for expense in viewModel.expenses {
            let month = formatter.string(from: expense.date)
            monthTotals[month, default: 0] += expense.amount
        }
        
        let entries = monthTotals.map { (month, total) in
            return PieChartDataEntry(value: total, label: month)
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "Monthly Expenses")
        dataSet.colors = ChartColorTemplates.material()
        
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
    }
}

extension DashboardVC: AddExpenseDelegate {
    func didAddExpense(_ expense: Expense) {
        viewModel.addExpense(expense)
        reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
        updateTotalExpense()
        updateCharts()
    }

    private func updateTotalExpense() {
        let total = viewModel.getExpenses().reduce(0) { $0 + $1.amount }
        totalExpenseLabel.text = "Total: ₹\(total)"
    }
}

extension DashboardVC: DashboardVCDelegate { // Call By ExpensesList VC
    func updateExpense(_ expense: Expense) {
        didAddExpense(expense)
    }
    
    func didDeleteExpense(_ expense: Expense) {
        viewModel.deleteExpense(expense.id)
        reloadData()
    }
}
