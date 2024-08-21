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
    
    private func fetchPosts() {
        let db = Firestore.firestore()
        db.collection("posts").getDocuments{(data, error) in
            if error == nil && data != nil{
                    self.posts = data?.documents.compactMap { document in
                                        return Post(dictionary: document.data(), id: document.documentID)
                                    } ?? []
                    print(self.posts)
                                    self.tableViewPosts.reloadData()
                
            }}}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPostDetail" {
            if let destinationVC = segue.destination as? PostDetailsController,
               let indexPath = tableViewPosts.indexPathForSelectedRow {
                let selectedPost = posts[indexPath.row]
                destinationVC.post = selectedPost
            }
        }
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

