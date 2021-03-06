//
//  UserListViewController.swift
//  nine
//
//  Created by User on 2021/06/09.
//

import UIKit
import FirebaseFirestore
import Nuke
import FirebaseAuth
import Firebase

class UserListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    private var selectedUsers: [User] = []
    
    @IBOutlet weak var userListTableView: UITableView!
    
    @IBOutlet weak var startChatButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        userListTableView.allowsMultipleSelection = true
        
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        startChatButton.addTarget(self, action: #selector(tappedStartChatButton), for: .touchUpInside)
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        fetchUserInfoFromFirebase()
    }
    
    @objc func tappedStartChatButton() {
        print("tapped")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid, partnerUid]
        let membersfcm = [self.selectedUser?.fcmToken]
        
        // group_chat
        let myfcmToken = UserDefaults.standard.value(forKey: notificationFcmToken) as? String ?? ""
        var groupMembers: [String] = [uid]
        var groupfcms: [String] = [myfcmToken]
        selectedUsers.forEach { user in
            groupMembers.append(user.uid ?? "")
            groupfcms.append(user.fcmToken)
        }
        
        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt": Timestamp(),
            "membersfcm": membersfcm,
            "groupMembers": groupMembers,
            "groupfcms": groupfcms,
        ] as [String : Any]
        
        print(docData)
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err {
                print("ChatRoom????????????????????????\(err)")
            }
            self.dismiss(animated: true, completion: nil)
            print("ChatRoom????????????????????????")
            
        }
        
    }
    
    
    private func fetchUserInfoFromFirebase() {
        Firestore.firestore().collection("users").getDocuments { (snapshots, err)  in
            if let err = err {
                print("user???????????????????????? \(err)")
                return
            }
            
            snapshots?.documents.forEach( { (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if uid == snapshot.documentID {
                    return
                }
                
                self.users.append(user)
                self.userListTableView.reloadData()
                
            } )
        
       }
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        let user = users[indexPath.row]
        self.selectedUser = user
        // group_chat
        self.selectedUsers.append(user)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // group_chat
        let  deselectUser = users[indexPath.row]
        var frag = 0
        for user in selectedUsers {
            if user.fcmToken == deselectUser.fcmToken {
                selectedUsers.remove(at: frag)
            }
            frag += 1
        }
        if selectedUsers.count == 0 {
            startChatButton.isEnabled = false
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
}

class UserListTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            
            usernameLabel.text = user?.username
            
            if let url = URL(string: user?.profileImageUrl ?? ""){
                Nuke.loadImage(with: url, into: userImageView)
            }
            
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 32.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
