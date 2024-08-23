import Foundation
import UIKit
import UniformTypeIdentifiers
import Firebase
import FirebaseFirestore
import FirebaseStorage

class AddNewPostController: UIViewController {
    
    @IBOutlet weak var expectedTimeTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var companyNameTF: UITextField!
    @IBOutlet weak var positionTF: UITextField!
    @IBOutlet weak var publishPostBtn: UIButton!
    @IBOutlet weak var fileNameLbl: UILabel!
    @IBOutlet weak var expectedTimeTypePV: UIPickerView!
    @IBOutlet weak var uploadFileLbl: UILabel!

    @IBOutlet weak var descriptionTV: UITextView!
    
    var selectedFileURL: URL?
    let pickerData = ["Hours","Days","Months"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openFilePicker))
        uploadFileLbl.isUserInteractionEnabled = true
        uploadFileLbl.addGestureRecognizer(tapGesture)
        
        publishPostBtn.isEnabled = false
        
        expectedTimeTypePV.delegate = self
        expectedTimeTypePV.dataSource = self

        expectedTimeTypePV.selectRow(0, inComponent: 0, animated: false)
    }
    
    @objc func openFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func publishNewPost(_ sender: Any) {
        guard let fileURL = selectedFileURL else {
            showAlert(message: "No file selected")
            return
        }
        guard
                let companyName = companyNameTF.text, !companyName.isEmpty,
                let jobPosition = positionTF.text, !jobPosition.isEmpty,
                let jobDescription = descriptionTV.text, !jobDescription.isEmpty,
                
                let location = locationTF.text, !location.isEmpty
            else {
                showAlert(message: "Please fill in all fields.")
                return
            }
        
        guard
            let estimatedDaysString = expectedTimeTF.text?.description, !estimatedDaysString.isEmpty,
            let estimatedDays = Float(estimatedDaysString)
        else{
            showAlert(message: "Enter a valid number for estimated time.")
            return
        }
        
        
        let selectedTimeType = pickerData[expectedTimeTypePV.selectedRow(inComponent: 0)]

        let estimatedDaysToComplete: Float
        switch selectedTimeType {
        case "Hours":
            estimatedDaysToComplete = estimatedDays / 24
        case "Days":
            estimatedDaysToComplete = estimatedDays
        case "Months":
            estimatedDaysToComplete = estimatedDays * 30
        default:
            estimatedDaysToComplete = estimatedDays
        }
        
        let postId = UUID().uuidString
        
        let storageRef = Storage.storage().reference().child("posts/\(postId).pdf")
        let uploadTask = storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                self.showAlert(message: "Error uploading file: \(error.localizedDescription)")
                return
            }
            
            let postDictionary: [String: Any] = [
                "companyName": companyName,
                "dateOfExpiration": Timestamp(date: Date()),
                "estimatedDaysToComplete": estimatedDaysToComplete,
                "jobDescription": jobDescription,
                "jobPosition": jobPosition,
                "location": location
            ]

            let post = Post(dictionary: postDictionary, id: postId)
            
            if let post = post {
                self.savePostToFirestore(post: post)
            } else {
                self.showAlert(message: "Failed to initialize Post object.")
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
        }
        self.dismiss(animated: true, completion: nil)
    }


    private func savePostToFirestore(post: Post) {
        let firestoreRef = Firestore.firestore().collection("posts").document(post.id)
        let postData: [String: Any] = post.toDictionary()
        
        firestoreRef.setData(postData) { error in
            if let error = error {
                print("Error saving post to Firestore: \(error)")
            } else {
                print("Post saved successfully!")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension AddNewPostController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        //selectedFileURL.startAccessingSecurityScopedResource()
        self.selectedFileURL = selectedFileURL
        fileNameLbl.text = selectedFileURL.lastPathComponent
        publishPostBtn.isEnabled = true
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
    }
}

extension AddNewPostController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedType = pickerData[row]
        print("Selected time type: \(selectedType)")
    }
}
