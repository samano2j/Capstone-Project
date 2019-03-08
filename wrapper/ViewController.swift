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
            
           
          /*  let m : Message.ComposeResult? = email.ComposeMessage(recpt_ids: [email.GetProfile().id!], body: "hello", subject: "test", reply_to_id: "", urgent: false)
            
            if (m != nil)
            {
                print("Sent message")
                email.SaveDraft(Msg: m!) //save draft
                
            }*/
            
            
            
            if (results != nil)
            {
                
                
                for mail in (results?.data)!
                {
                    
                    
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
                    if (msg?.data.attributes.body == "hello")
                    {
                        print(email.DeleteMessage(folder_id: String((msg?.data.attributes.folder_id)!), message_id: (msg?.data.id)!))
                    }
                    
                    print(msg?.data.attributes.body)
                    //email.GetSenderInformation(Message: msg!)
                    
                    
                    
                    
                }
                
            }
        }
    }
    
    
}


