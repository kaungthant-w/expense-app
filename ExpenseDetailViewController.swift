import UIKit
import Foundation

// MARK: - Data Model
struct Expense {
    let id: UUID
    var name: String
    var price: Decimal
    var description: String
    var date: Date
    var time: Date
    var currency: String
    
    init(id: UUID = UUID(), name: String = "", price: Decimal = 0, description: String = "", date: Date = Date(), time: Date = Date(), currency: String = "USD") {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.date = date
        self.time = time
        self.currency = currency
    }
}

// MARK: - Delegate Protocol
protocol ExpenseDetailDelegate: AnyObject {
    func expenseDetailDidSave(_ expense: Expense)
    func expenseDetailDidDelete(_ expenseId: UUID)
}

// MARK: - Main View Controller
class ExpenseDetailViewController: UIViewController {
    
    // MARK: - Properties
    private var expense: Expense?
    private var isNewExpense: Bool = false
    weak var delegate: ExpenseDetailDelegate?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    
    // Header Section
    private let headerStackView = UIStackView()
    private let backButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
    
    // Main Content Card
    private let contentCardView = UIView()
    private let cardStackView = UIStackView()
    
    // Form Fields
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    
    private let priceLabel = UILabel()
    private let priceTextField = UITextField()
    
    private let descriptionLabel = UILabel()
    private let descriptionTextView = UITextView()
    
    private let dateTimeStackView = UIStackView()
    private let dateLabel = UILabel()
    private let dateTextField = UITextField()
    private let timeLabel = UILabel()
    private let timeTextField = UITextField()
    
    // Action Buttons
    private let buttonStackView = UIStackView()
    private let saveButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    
    // Date Pickers
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()
    
    // MARK: - Initialization
    init(expense: Expense? = nil) {
        self.expense = expense
        self.isNewExpense = expense == nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        configureForCurrentExpense()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.expenseBackgroundColor
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure main stack view
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        setupHeader()
        setupContentCard()
        setupFormFields()
        setupActionButtons()
        
        // Add to view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(headerStackView)
        mainStackView.addArrangedSubview(contentCardView)
        mainStackView.addArrangedSubview(buttonStackView)
    }
    
    private func setupHeader() {
        // Header stack view
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.distribution = .fill
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Back button
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor.expensePrimaryText
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        titleLabel.font = UIFont.expenseTitleFont
        titleLabel.textColor = UIColor.expensePrimaryText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerStackView.addArrangedSubview(backButton)
        headerStackView.addArrangedSubview(titleLabel)
        
        // Header constraints
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: ExpenseSpacing.headerHeight),
            backButton.heightAnchor.constraint(equalToConstant: ExpenseSpacing.headerHeight),
            headerStackView.heightAnchor.constraint(equalToConstant: ExpenseSpacing.headerHeight)
        ])
        
        // Header margins
        mainStackView.setCustomSpacing(ExpenseSpacing.xxLarge - ExpenseSpacing.small, after: headerStackView)
    }
    
    private func setupContentCard() {
        // Content card view
        contentCardView.backgroundColor = UIColor.expenseCardBackground
        contentCardView.layer.cornerRadius = ExpenseSpacing.cardCornerRadius
        contentCardView.layer.shadowColor = UIColor.expenseCardShadow.cgColor
        contentCardView.layer.shadowOffset = ExpenseShadow.cardShadowOffset
        contentCardView.layer.shadowRadius = ExpenseShadow.cardShadowRadius
        contentCardView.layer.shadowOpacity = ExpenseShadow.cardShadowOpacity
        contentCardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Card stack view
        cardStackView.axis = .vertical
        cardStackView.spacing = ExpenseSpacing.fieldSpacing
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentCardView.addSubview(cardStackView)
        
        // Card constraints
        NSLayoutConstraint.activate([
            cardStackView.topAnchor.constraint(equalTo: contentCardView.topAnchor, constant: ExpenseSpacing.cardPadding),
            cardStackView.leadingAnchor.constraint(equalTo: contentCardView.leadingAnchor, constant: ExpenseSpacing.cardPadding),
            cardStackView.trailingAnchor.constraint(equalTo: contentCardView.trailingAnchor, constant: -ExpenseSpacing.cardPadding),
            cardStackView.bottomAnchor.constraint(equalTo: contentCardView.bottomAnchor, constant: -ExpenseSpacing.cardPadding)
        ])
        
        mainStackView.setCustomSpacing(ExpenseSpacing.cardMargin, after: contentCardView)
    }
    
    private func setupFormFields() {
        setupNameField()
        setupPriceField()
        setupDescriptionField()
        setupDateTimeFields()
    }
    
    private func setupNameField() {
        // Name label
        nameLabel.text = localizedString("name_label")
        nameLabel.font = UIFont.expenseLabelFont
        nameLabel.textColor = UIColor.expenseSecondaryText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Name text field
        nameTextField.font = UIFont.expenseInputFont
        nameTextField.textColor = UIColor.expenseInputText
        nameTextField.backgroundColor = UIColor.expenseInputBackground
        nameTextField.layer.cornerRadius = ExpenseSpacing.inputCornerRadius
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.expenseInputBorder.cgColor
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: ExpenseSpacing.medium, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: ExpenseSpacing.medium, height: 0))
        nameTextField.rightViewMode = .always
        nameTextField.placeholder = localizedString("placeholder_name")
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility
        nameTextField.accessibilityLabel = localizedString("accessibility_expense_name")
        
        let nameStackView = UIStackView(arrangedSubviews: [nameLabel, nameTextField])
        nameStackView.axis = .vertical
        nameStackView.spacing = ExpenseSpacing.small
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        
        cardStackView.addArrangedSubview(nameStackView)
        
        NSLayoutConstraint.activate([
            nameTextField.heightAnchor.constraint(equalToConstant: ExpenseSpacing.inputHeight)
        ])
    }
    
    private func setupPriceField() {
        // Price label
        priceLabel.text = localizedString("price_label")
        priceLabel.font = UIFont.expenseLabelFont
        priceLabel.textColor = UIColor.expenseSecondaryText
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Price text field
        priceTextField.font = UIFont.expenseInputFont
        priceTextField.textColor = UIColor.expenseAccentColor
        priceTextField.backgroundColor = UIColor.expenseInputBackground
        priceTextField.layer.cornerRadius = ExpenseSpacing.inputCornerRadius
        priceTextField.layer.borderWidth = 1
        priceTextField.layer.borderColor = UIColor.expenseInputBorder.cgColor
        priceTextField.keyboardType = .decimalPad
        priceTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: ExpenseSpacing.medium, height: 0))
        priceTextField.leftViewMode = .always
        priceTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: ExpenseSpacing.medium, height: 0))
        priceTextField.rightViewMode = .always
        priceTextField.placeholder = localizedString("placeholder_price")
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility
        priceTextField.accessibilityLabel = localizedString("accessibility_expense_price")
        
        let priceStackView = UIStackView(arrangedSubviews: [priceLabel, priceTextField])
        priceStackView.axis = .vertical
        priceStackView.spacing = ExpenseSpacing.small
        priceStackView.translatesAutoresizingMaskIntoConstraints = false
        
        cardStackView.addArrangedSubview(priceStackView)
        
        NSLayoutConstraint.activate([
            priceTextField.heightAnchor.constraint(equalToConstant: ExpenseSpacing.inputHeight)
        ])
    }
    
    private func setupDescriptionField() {
        // Description label
        descriptionLabel.text = "📝 Description"
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = UIColor.secondaryLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description text view
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.textColor = UIColor.label
        descriptionTextView.backgroundColor = UIColor.tertiarySystemBackground
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.separator.cgColor
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        descriptionTextView.isScrollEnabled = true
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility
        descriptionTextView.accessibilityLabel = "Expense description"
        
        let descriptionStackView = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextView])
        descriptionStackView.axis = .vertical
        descriptionStackView.spacing = 8
        descriptionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        cardStackView.addArrangedSubview(descriptionStackView)
        
        NSLayoutConstraint.activate([
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    private func setupDateTimeFields() {
        // Date time stack view
        dateTimeStackView.axis = .horizontal
        dateTimeStackView.distribution = .fillEqually
        dateTimeStackView.spacing = 16
        dateTimeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Date field
        let dateStackView = UIStackView()
        dateStackView.axis = .vertical
        dateStackView.spacing = 8
        
        dateLabel.text = "📅 Date"
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor.secondaryLabel
        
        dateTextField.font = UIFont.boldSystemFont(ofSize: 16)
        dateTextField.textColor = UIColor.label
        dateTextField.backgroundColor = UIColor.tertiarySystemBackground
        dateTextField.layer.cornerRadius = 8
        dateTextField.layer.borderWidth = 1
        dateTextField.layer.borderColor = UIColor.separator.cgColor
        dateTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        dateTextField.leftViewMode = .always
        dateTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        dateTextField.rightViewMode = .always
        dateTextField.accessibilityLabel = "Expense date"
        
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(dateTextField)
        
        // Time field
        let timeStackView = UIStackView()
        timeStackView.axis = .vertical
        timeStackView.spacing = 8
        
        timeLabel.text = "🕐 Time"
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.secondaryLabel
        
        timeTextField.font = UIFont.boldSystemFont(ofSize: 16)
        timeTextField.textColor = UIColor.label
        timeTextField.backgroundColor = UIColor.tertiarySystemBackground
        timeTextField.layer.cornerRadius = 8
        timeTextField.layer.borderWidth = 1
        timeTextField.layer.borderColor = UIColor.separator.cgColor
        timeTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        timeTextField.leftViewMode = .always
        timeTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        timeTextField.rightViewMode = .always
        timeTextField.accessibilityLabel = "Expense time"
        
        timeStackView.addArrangedSubview(timeLabel)
        timeStackView.addArrangedSubview(timeTextField)
        
        dateTimeStackView.addArrangedSubview(dateStackView)
        dateTimeStackView.addArrangedSubview(timeStackView)
        
        cardStackView.addArrangedSubview(dateTimeStackView)
        
        NSLayoutConstraint.activate([
            dateTextField.heightAnchor.constraint(equalToConstant: 50),
            timeTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        setupDatePickers()
    }
    
    private func setupDatePickers() {
        // Date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        dateTextField.inputView = datePicker
        
        // Time picker
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timeTextField.inputView = timePicker
        
        // Add toolbars for date/time pickers
        let dateToolbar = createPickerToolbar(for: dateTextField)
        dateTextField.inputAccessoryView = dateToolbar
        
        let timeToolbar = createPickerToolbar(for: timeTextField)
        timeTextField.inputAccessoryView = timeToolbar
    }
    
    private func createPickerToolbar(for textField: UITextField) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(pickerDoneButtonTapped)
        )
        
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        toolbar.items = [flexSpace, doneButton]
        return toolbar
    }
    
    private func setupActionButtons() {
        // Button stack view
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = ExpenseSpacing.small
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Save button
        saveButton.setTitle(localizedString("save_button"), for: .normal)
        saveButton.titleLabel?.font = UIFont.expenseButtonFont
        saveButton.backgroundColor = UIColor.expensePrimaryButton
        saveButton.setTitleColor(UIColor.expenseButtonText, for: .normal)
        saveButton.layer.cornerRadius = ExpenseSpacing.buttonCornerRadius
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.accessibilityLabel = localizedString("accessibility_save_expense")
        
        // Delete button
        deleteButton.setTitle(localizedString("delete_button"), for: .normal)
        deleteButton.titleLabel?.font = UIFont.expenseButtonFont
        deleteButton.backgroundColor = UIColor.expenseDestructiveButton
        deleteButton.setTitleColor(UIColor.expenseButtonText, for: .normal)
        deleteButton.layer.cornerRadius = ExpenseSpacing.buttonCornerRadius
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.accessibilityLabel = localizedString("accessibility_delete_expense")
        
        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: ExpenseSpacing.buttonHeight),
            deleteButton.heightAnchor.constraint(equalToConstant: ExpenseSpacing.buttonHeight)
        ])
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let horizontalMargin = ExpenseLayout.horizontalMargin(for: traitCollection)
        
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Main stack view constraints
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ExpenseSpacing.medium),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalMargin),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalMargin),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ExpenseSpacing.large)
        ])
        
        // Content max width for iPad
        let maxWidth = ExpenseLayout.contentMaxWidth(for: traitCollection)
        if maxWidth != .greatestFiniteMagnitude {
            mainStackView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
            mainStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        
        // Add character limit to name field
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        
        // Add character limit to description field
        descriptionTextView.delegate = self
        
        // Add price validation
        priceTextField.addTarget(self, action: #selector(priceTextFieldChanged), for: .editingChanged)
    }
    
    private func configureForCurrentExpense() {
        if isNewExpense {
            titleLabel.text = NSLocalizedString("Add Expense", comment: "")
            expense = Expense()
            deleteButton.isHidden = true
        } else {
            titleLabel.text = NSLocalizedString("Edit Expense", comment: "")
            deleteButton.isHidden = false
        }
        
        guard let expense = expense else { return }
        
        nameTextField.text = expense.name
        priceTextField.text = formatPrice(expense.price)
        descriptionTextView.text = expense.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateTextField.text = dateFormatter.string(from: expense.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeTextField.text = timeFormatter.string(from: expense.time)
        
        datePicker.date = expense.date
        timePicker.date = expense.time
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        saveButton.transform = CGAffineTransform(scaleX: ExpenseAnimation.buttonScaleDown, y: ExpenseAnimation.buttonScaleDown)
        UIView.animate(withDuration: ExpenseAnimation.shortDuration) {
            self.saveButton.transform = .identity
        }
        
        guard validateInput() else { return }
        
        var updatedExpense = expense ?? Expense()
        updatedExpense.name = nameTextField.text ?? ""
        updatedExpense.price = Decimal(string: priceTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0
        updatedExpense.description = descriptionTextView.text
        updatedExpense.date = datePicker.date
        updatedExpense.time = timePicker.date
        
        self.expense = updatedExpense
        delegate?.expenseDetailDidSave(updatedExpense)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        deleteButton.transform = CGAffineTransform(scaleX: ExpenseAnimation.buttonScaleDown, y: ExpenseAnimation.buttonScaleDown)
        UIView.animate(withDuration: ExpenseAnimation.shortDuration) {
            self.deleteButton.transform = .identity
        }
        
        guard let expense = expense else { return }
        
        let alert = UIAlertController(
            title: localizedString("delete_expense_title"),
            message: localizedString("delete_expense_message"),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: localizedString("cancel_button"), style: .cancel))
        alert.addAction(UIAlertAction(title: localizedString("delete_button"), style: .destructive) { _ in
            self.delegate?.expenseDetailDidDelete(expense.id)
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func pickerDoneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc private func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc private func timePickerValueChanged() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeTextField.text = timeFormatter.string(from: timePicker.date)
    }
    
    @objc private func nameTextFieldChanged() {
        guard let text = nameTextField.text else { return }
        if text.count > ExpenseLayout.maxNameLength {
            nameTextField.text = String(text.prefix(ExpenseLayout.maxNameLength))
            // Shake animation for character limit
            shakeView(nameTextField)
        }
    }
    
    @objc private func priceTextFieldChanged() {
        guard let text = priceTextField.text else { return }
        
        // Remove non-numeric characters except decimal point
        let filteredText = text.filter { $0.isNumber || $0 == "." || $0 == "," }
        
        // Validate decimal format (12 digits before, 2 after)
        let components = filteredText.replacingOccurrences(of: ",", with: ".").components(separatedBy: ".")
        
        if components.count > 2 {
            priceTextField.text = String(filteredText.dropLast())
            shakeView(priceTextField)
        } else if components.count == 2 {
            let beforeDecimal = components[0]
            let afterDecimal = components[1]
            
            if beforeDecimal.count > ExpenseLayout.maxPriceDigitsBeforeDecimal || afterDecimal.count > ExpenseLayout.maxPriceDigitsAfterDecimal {
                priceTextField.text = String(filteredText.dropLast())
                shakeView(priceTextField)
            }
        } else if components[0].count > ExpenseLayout.maxPriceDigitsBeforeDecimal {
            priceTextField.text = String(filteredText.dropLast())
            shakeView(priceTextField)
        }
    }
    
    // MARK: - Helper Methods
    private func validateInput() -> Bool {
        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            shakeView(nameTextField)
            nameTextField.becomeFirstResponder()
            return false
        }
        
        guard let priceText = priceTextField.text, !priceText.isEmpty,
              let _ = Decimal(string: priceText.replacingOccurrences(of: ",", with: ".")) else {
            shakeView(priceTextField)
            priceTextField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: price)) ?? "0"
    }
    
    private func shakeView(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = ExpenseAnimation.longDuration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        view.layer.add(animation, forKey: "shake")
    }
}

// MARK: - UITextViewDelegate
extension ExpenseDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if updatedText.count > ExpenseLayout.maxDescriptionLength {
            shakeView(textView)
            return false
        }
        
        return true
    }
}

// MARK: - Localization Extensions
extension ExpenseDetailViewController {
    private func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
