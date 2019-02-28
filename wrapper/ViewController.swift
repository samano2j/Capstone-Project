import UIKit

class ViewController: UIViewController {
    
    func callback(data: String, error: String?) {
        
        if (error == nil) {
            print(data)
        }
        else
        {
            print("Error -> \(String(describing: error))")
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var Messages : Message.result? = nil
        
        let email = Email(url: "http://otu-capstone.cs.uregina.ca:3000")
        
        
        
        if ( email.Auth(User: "max", Password: "1234") == true )
        {
            
            var results : Folder.result? = nil
            results = email.GetFolders()
            
            email.GetProfile()
            
            if (results != nil)
            {
                
                
                for mail in (results?.data)!
                {
                    print("test")
                    
                    if (mail.attributes.name == "Inbox")
                    {
                        Messages = email.GetMessages(folder_id: mail.id)
                        
                        break
                    }
                }
            }
        }
        
        
        
        
        if (Messages != nil)
        {
            
            for Message in (Messages?.data)!
            {
                
                
                let msg = email.GetMessage(folder_id: String(Message.attributes.folder_id), message_id: Message.id)
                
                if (msg != nil)
                {
                    email.GetSenderInformation(Message: msg!)
                    
                    
                    
                    
                }
                
            }
        }
    }
    
    
}


