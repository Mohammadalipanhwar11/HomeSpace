import FirebaseFirestore
import UIKit
import FirebaseAuth

class SearchAllGroupsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchControllerDelegate {
    
    @IBOutlet weak var searchTableView: UITableView!
    
    var selectedText:String?
    var selectedKey:String?
    var moveText:String?
    var deleteID:String?
    var deleteTitle:String?
    var reminder:String?
    var index:Int?
    var groupId:String?
    
    var data = [(group:Group,tasks:[Task])]()
    var currentTask = [(group:Group,tasks:[Task])]()
    var task = [(group:Group,tasks:[Task])]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dict = UserDefaults.standard.value(forKey: "dict") as? [String:String]{
            var dict = dict
            if let _ = dict["openGroup"]{
                dict["openGroup"] = ""
                UserDefaults.standard.set(dict, forKey: "dict")
            }
        }
        Firestore.firestore().collection("tasks").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { (snapshot, error) in
            self.searchBar.searchTextField.text = ""
            self.data = Task.sharedSearch
            self.searchTableView.reloadData()
        }
        Firestore.firestore().collection("groups").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { (snapshot, error) in
            self.searchBar.searchTextField.text = ""
            self.data = Task.sharedSearch
            self.searchTableView.reloadData()
        }
        
        self.task = data
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.customizeSearchBar()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        self.task = self.data
        self.task.removeAll()
        searchBar.searchTextField.resignFirstResponder()
        self.searchTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if self.searchBar.text == ""{
            self.task.removeAll()
            self.searchTableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.searchBar.text == ""{
            self.task.removeAll()
            self.searchTableView.reloadData()
        }else{
            guard !searchText.isEmpty else {currentTask = task;
                self.task = data;
                self.searchTableView.reloadData();
                return
            }
            
            currentTask = self.data.map { (item) ->  (group:Group,tasks:[Task]) in
                let filtered = item.tasks.filter { (t) -> Bool in
                    return t.name!.lowercased().contains(searchText.lowercased())
                }
                return (item.group,filtered)
            }
            self.currentTask = self.currentTask.filter({(ct) -> Bool in
                ct.tasks.count != 0
            })
            self.task = currentTask
            self.searchTableView.reloadData()
        }
    }
    
    func customizeSearchBar(){
        self.searchBar.delegate = self
        
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        
        let glassIconView = textField.leftView as! UIImageView
        textField.textColor = UIColor(red: 43/255, green: 151/255, blue: 240/255, alpha: 1.0)
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor(red: 43/255, green: 151/255, blue: 240/255, alpha: 1.0)
        
        
        let clearButton = textField.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor(red: 43/255, green: 151/255, blue: 240/255, alpha: 1.0)
        
        searchBar.borderWidth = 3.0
        searchBar.borderColor = UIColor(red: 43/255, green: 151/255, blue: 240/255, alpha: 1.0)
        searchBar.cornerRadius = 30/2
        
        var r = self.view.frame
        r.origin.y = -44
        r.size.height += 44
        
        self.view.frame = r
        searchBar.setShowsCancelButton(true, animated: true)
        
        self.searchBar.becomeFirstResponder()
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "edit" {
//            let dest = segue.destination as! editTaskViewController
//            dest.text = selectedText
//            dest.key1 = selectedKey
//            dest.groupID = self.groupId
//            dest.deleteID = self.deleteID
//            dest.deleteTitle = self.deleteTitle
//            dest.reminder = self.reminder
//        }
//    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SearchAllGroupsViewController{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupID = self.task[indexPath.section].tasks[indexPath.row].group
        staticLinker.rootVc.changePage(groupID: groupID!)
        self.navigationController?.popViewController(animated: true)
        
//        self.selectedText = self.task[indexPath.section].tasks[indexPath.row].name
//        self.selectedKey = self.task[indexPath.section].tasks[indexPath.row].id
//        self.moveText = self.task[indexPath.section].tasks[indexPath.row].name
//        self.deleteID = self.task[indexPath.section].tasks[indexPath.row].id
//        self.deleteTitle = self.task[indexPath.section].group.name
//        self.reminder = self.task[indexPath.section].tasks[indexPath.row].reminder
//        self.groupId = self.task[indexPath.section].group.id
//        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor(red: 43/255, green: 151/255, blue: 240/255, alpha: 1.0)
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor=title.textColor
        header.contentView.backgroundColor = UIColor.darkGray
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.task[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchCell") as! tasksTableViewCell
        cell.taskLabel.text = self.task[indexPath.section].1[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.task[section].group.name?.capitalized
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.task.count
    }
    
}

//
//extension UISearchBar {
//
//    var textField : UITextField? {
//        if #available(iOS 13.0, *) {
//                return self.searchTextField
//        } else {
//            // Fallback on earlier versions
//            for view : UIView in (self.subviews[0]).subviews {
//                if let textField = view as? UITextField {
//                    return textField
//                }
//            }
//        }
//        return nil
//    }
//}
