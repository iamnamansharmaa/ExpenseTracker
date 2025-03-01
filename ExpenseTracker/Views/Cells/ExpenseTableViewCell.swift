//
//  ExpenseTableViewCell.swift
//  ExpenseTracker
//
//  Created by Naman Sharma on 24/02/25.
//
import UIKit
class ExpenseTableViewCell: UITableViewCell {
    static let identifier = "ExpenseCell"

    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let categoryLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        amountLabel.font = .systemFont(ofSize: 14, weight: .medium)
        categoryLabel.font = .systemFont(ofSize: 14, weight: .regular)
        categoryLabel.textColor = .gray

        let stackView = UIStackView(arrangedSubviews: [titleLabel, amountLabel, categoryLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with expense: Expense) {
        titleLabel.text = expense.title
        amountLabel.text = "₹\(expense.amount)"
        categoryLabel.text = "Category: \(expense.category.rawValue)"
    }
}
