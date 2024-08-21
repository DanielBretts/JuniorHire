import Foundation
import FirebaseFirestore

struct Post {
    let id: String
    let companyName: String
    let dateOfExpiration: Date
    let estimatedDaysToComplete: Int
    let jobDescription: String
    let jobPosition: String
    
    init?(dictionary: [String: Any], id: String) {
        guard let companyName = dictionary["companyName"] as? String,
              let dateOfExpirationTimestamp = dictionary["dateOfExpiration"] as? Timestamp,
              let estimatedDaysToComplete = dictionary["estimatedDaysToComplete"] as? Int,
              let jobDescription = dictionary["jobDescription"] as? String,
              let jobPosition = dictionary["jobPosition"] as? String else {
            return nil
        }
        
        self.id = id
        self.companyName = companyName
        self.dateOfExpiration = dateOfExpirationTimestamp.dateValue()
        self.estimatedDaysToComplete = estimatedDaysToComplete
        self.jobDescription = jobDescription
        self.jobPosition = jobPosition
    }
}
