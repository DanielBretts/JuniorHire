import Foundation
import FirebaseFirestore

struct Post {
    let id: String
    let companyName: String
    let dateOfExpiration: Date
    let estimatedDaysToComplete: Float
    let jobDescription: String
    let jobPosition: String
    let location: String
    
    init?(dictionary: [String: Any], id: String) {
        guard let companyName = dictionary["companyName"] as? String,
              let dateOfExpirationTimestamp = dictionary["dateOfExpiration"] as? Timestamp,
              let estimatedDaysToComplete = dictionary["estimatedDaysToComplete"] as? Float,
              let jobDescription = dictionary["jobDescription"] as? String,
              let location = dictionary["location"] as? String,
              let jobPosition = dictionary["jobPosition"] as? String else {
            return nil
        }
        
        self.id = id
        self.companyName = companyName
        self.dateOfExpiration = dateOfExpirationTimestamp.dateValue()
        self.estimatedDaysToComplete = estimatedDaysToComplete
        self.jobDescription = jobDescription
        self.jobPosition = jobPosition
        self.location = location
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "companyName": companyName,
            "dateOfExpiration": Timestamp(date: dateOfExpiration), // Convert Date to Timestamp
            "estimatedDaysToComplete": estimatedDaysToComplete,
            "jobDescription": jobDescription,
            "jobPosition": jobPosition,
            "location": location
        ]
    }
}
