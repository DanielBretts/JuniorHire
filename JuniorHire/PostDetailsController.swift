import UIKit
import WebKit
import FirebaseStorage

class PostDetailsController: UIViewController {
    
    @IBOutlet weak var positionTitleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var remainingDaysLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var assignmentWK: WKWebView!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI with post details
        if let post = post {
            positionTitleLbl.text = post.jobPosition
            companyNameLbl.text = "at \(post.companyName)"
            remainingDaysLbl.text = "Approximate time to finish: \(post.estimatedDaysToComplete) Days"
            descriptionLbl.text = post.jobDescription
            
            // Formatting date for display
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
        }
        
        // Fetch and load PDF
        fetchAndLoadPDF()
    }
    
    private func fetchAndLoadPDF() {
        guard let postId = post?.id else {
            print("Post ID is missing")
            return
        }
        
        // Reference to your Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Create a reference to the PDF file using the post ID
        let pdfRef = storageRef.child("posts").child("\(postId).pdf")
        
        // Fetch the download URL for the PDF file
        pdfRef.downloadURL { [weak self] (url, error) in
            if let error = error {
                print("Error fetching download URL: \(error.localizedDescription)")
                return
            }
            
            guard let url = url else {
                print("Download URL is nil")
                return
            }
            
            // Load the PDF URL in WKWebView
            let request = URLRequest(url: url)
            DispatchQueue.main.async {
                self?.assignmentWK.load(request)
            }
        }
    }
}
