//
//  ChatListViewController.swift
//  nine
//
//  Created by User on 2021/05/27.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Nuke



class ChatListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    private var chatRoomListener: ListenerRegistration?
    
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        setUpViews()
        confirmLoggedInUser()
        fetchChatroomInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchLoginUserInfo()
        
    }
    
    
    
    func fetchChatroomInfoFromFirestore() {
        chatRoomListener?.remove()
        chatrooms.removeAll()
        chatListTableView.reloadData()
        
        
        chatRoomListener = Firestore.firestore().collection("chatRooms")
            .addSnapshotListener {(snapshots, err) in
                
                if let err = err {
                    print("ChatRooms情報の取得に失敗\(err)")
                    return
                }
                
                snapshots?.documentChanges.forEach( { (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                        
                    case .modified, .removed:
                        print("nothing")
                        
                    }
                    
                } )
            }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        let documentId = documentChange.document.documentID
        chatroom.documentID = documentChange.document.documentID
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isContain = chatroom.groupMembers.contains(uid)
        if !isContain {return}
        
       //処理
        fetchUsersData(uid: uid, documentId: documentId, chatroom: chatroom) { chatroom in
            if let chatroom = chatroom {
                //group
                guard let chatroomId = chatroom.documentID else { return }
                let latestMessageId = chatroom.latestMessageId
                
                if latestMessageId == "" {
                    self.chatrooms.append(chatroom)
                    self.chatListTableView.reloadData()
                    return
                }
                
                Firestore.firestore().collection("chatRooms").document(chatroomId).collection("messages").document(latestMessageId).getDocument { (messageSnapshot, err) in
                    if let err = err {
                        print("最新情報の取得に失敗\(err)")
                        return
                    }
                    
                    guard let dic = messageSnapshot?.data() else { return }
                    let message = Message(dic: dic)
                    chatroom.latestMessage = message
                    self.chatrooms.append(chatroom)
                    self.chatListTableView.reloadData()
                }
            }
        }
    }
    private func fetchUsersData(uid: String, documentId: String, chatroom: ChatRoom, complite: @escaping (ChatRoom?) -> ()) {
        var frag = 1
        chatroom.groupMembers.forEach { (memberUid) in
            if memberUid != uid {
                fetchUser(memberUid: memberUid,documentId: documentId) { user in
                    frag += 1
                    if let user = user {
                        chatroom.partnerUser = user
                        chatroom.groupUsers.append(user)
                    }
                    if frag == chatroom.groupMembers.count {
                        complite(chatroom)
                    }
                }
            }
        }
    }
    // Userを一人一人fetch
    private func fetchUser(memberUid: String, documentId: String,complite: @escaping (User?) -> ()) {
        Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗\(err)")
                complite(nil)
            }
            guard let dic = userSnapshot?.data() else { return }
            let user = User(dic: dic)
            user.uid = documentId
            complite(user)
            
            print()
        }
    }
    
    private func setUpViews() {
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let rigntBarButton = UIBarButtonItem(title: "チャット新規", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        let logoutBarButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedLogoutButton))
        
        navigationItem.rightBarButtonItem = rigntBarButton
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem = logoutBarButton
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc private func tappedLogoutButton() {
        do {
            try Auth.auth().signOut()
            pushLoginViewController()
        } catch {
            print ("ログアウトに失敗\(error)")
        }
        
    }
    
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            pushLoginViewController()
        }
    }
    
    private func pushLoginViewController() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")as! SignUpViewController
        
        let nav = UINavigationController(rootViewController: signUpViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc private func tappedNavRightBarButton() {
        
        let storyboad = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewController = storyboad.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    private func fetchLoginUserInfo() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗\(err)")
                return
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            let user = User(dic: dic)
            self.user = user
            
            
        }
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped table view")
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
<<<<<<< HEAD
        
        print()
=======

>>>>>>> feature/save-fcmToken
    }
    
}

class ChatListTableViewCell: UITableViewCell {
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dateFormatterForDateLabel(date: chatroom.latestMessage?.createdAt.dateValue() ?? Date())
                latestMessageLabel.text = chatroom.latestMessage?.message
            }
            
        }
    }
    
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
