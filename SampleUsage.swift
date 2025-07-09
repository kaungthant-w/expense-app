import UIKit

// MARK: - Sample Usage of ExpenseDetailViewController
class SampleExpenseListViewController: UIViewController {
    
    // MARK: - Properties
    private var expenses: [Expense] = []
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSampleData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.expenseBackgroundColor
        title = "Expenses"
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.expenseBackgroundColor
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExpenseCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup add button
        addButton.setTitle("Add New Expense", for: .normal)
        addButton.backgroundColor = UIColor.expensePrimaryButton
        addButton.setTitleColor(UIColor.expenseButtonText, for: .normal)
        addButton.layer.cornerRadius = ExpenseSpacing.buttonCornerRadius
        addButton.titleLabel?.font = UIFont.expenseButtonFont
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        // Add to view hierarchy
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        // Setup constraints
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -ExpenseSpacing.medium),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ExpenseSpacing.medium),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ExpenseSpacing.medium),
            addButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -ExpenseSpacing.medium),
            addButton.heightAnchor.constraint(equalToConstant: ExpenseSpacing.buttonHeight)
        ])
    }
    
    private func setupSampleData() {
        // Add some sample expenses
        expenses = [
            Expense(name: "Coffee", price: 4.50, description: "Morning coffee at the local cafe", date: Date(), time: Date()),
            Expense(name: "Lunch", price: 12.99, description: "Lunch with colleagues", date: Date(), time: Date()),
            Expense(name: "Gas", price: 45.00, description: "Fuel for the car", date: Date(), time: Date())
        ]
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        presentExpenseDetail(expense: nil)
    }
    
    private func presentExpenseDetail(expense: Expense?) {
        let detailVC = ExpenseDetailViewController(expense: expense)
        detailVC.delegate = self
        
        // You can present modally or push to navigation stack
        if let navigationController = navigationController {
            navigationController.pushViewController(detailVC, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: detailVC)
            present(navController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension SampleExpenseListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        let expense = expenses[indexPath.row]
        
        // Configure cell
        cell.textLabel?.text = expense.name
        cell.detailTextLabel?.text = "$\(expense.price)"
        cell.backgroundColor = UIColor.expenseCardBackground
        cell.layer.cornerRadius = ExpenseSpacing.inputCornerRadius
        cell.layer.marginTop = ExpenseSpacing.small
        cell.layer.marginBottom = ExpenseSpacing.small
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SampleExpenseListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let expense = expenses[indexPath.row]
        presentExpenseDetail(expense: expense)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - ExpenseDetailDelegate
extension SampleExpenseListViewController: ExpenseDetailDelegate {
    func expenseDetailDidSave(_ expense: Expense) {
        // Find existing expense or add new one
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
        } else {
            expenses.append(expense)
        }
        
        tableView.reloadData()
        
        // Show success feedback
        let alert = UIAlertController(title: "Success", message: "Expense saved successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func expenseDetailDidDelete(_ expenseId: UUID) {
        expenses.removeAll { $0.id == expenseId }
        tableView.reloadData()
        
        // Show success feedback
        let alert = UIAlertController(title: "Deleted", message: "Expense deleted successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Scene Delegate Integration Example
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Create the expense list as root view controller
        let expenseListVC = SampleExpenseListViewController()
        let navigationController = UINavigationController(rootViewController: expenseListVC)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
