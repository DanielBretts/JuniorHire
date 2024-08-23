//
//  ViewController.swift
//  JuniorHire
//
//  Created by amit lupo  on 7/27/24.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet weak var tableViewPosts: UITableView!
    
    private var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Registering a class-based cell
        tableViewPosts.register(JobPostTableViewCell.self, forCellReuseIdentifier: "JobPostTableViewCell")

        // Registering a nib-based cell
        tableViewPosts.register(UINib(nibName: "JobPostTableViewCell", bundle: nil), forCellReuseIdentifier: "JobPostTableViewCell")

        tableViewPosts.dataSource = self
        tableViewPosts.delegate = self
        
        fetchPosts()
    }
    
    private var listener: ListenerRegistration?

    private func fetchPosts() {
        let db = Firestore.firestore()
        
        // Set up the Firestore listener
        listener = db.collection("posts").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching posts: \(error)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("No posts found")
                return
            }
            
            self.posts = snapshot.documents.compactMap { document in
                return Post(dictionary: document.data(), id: document.documentID)
            }
            
            print("Posts updated: \(self.posts)")
            self.tableViewPosts.reloadData()
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPostDetail" {
            if let destinationVC = segue.destination as? PostDetailsController,
               let indexPath = tableViewPosts.indexPathForSelectedRow {
                let selectedPost = posts[indexPath.row]
                destinationVC.post = selectedPost
            }
        }
    }
    
    
    @IBAction func addNewPost(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
                let secondController = storyboard.instantiateViewController(withIdentifier: "AddNewPostView")
                self.present(secondController, animated: true,completion: nil)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JobPostTableViewCell", for: indexPath) as? JobPostTableViewCell else {
            return UITableViewCell() // Return a default cell if casting fails
        }
        
        let post = posts[indexPath.row]
        
        cell.positionTitleLbl.text = post.jobPosition
        cell.companyNameLbl.text = "at \(post.companyName)"
        cell.remainingDaysLbl.text = "\(post.estimatedDaysToComplete) Days"
        cell.descriptionLbl.text = post.jobDescription
        cell.locationLbl.text = "📍\(post.location)"
        
        // Formatting date for display
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        cell.dateOfExpirationLbl.text = (dateFormatter.string(from: post.dateOfExpiration))

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPostDetail", sender: self)
    }
    
    


}

