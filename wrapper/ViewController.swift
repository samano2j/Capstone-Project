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
            
            let matches : Profile.MatchUserResult? =  email.GetMatchings()
            
            if (matches != nil)
            {
                for match in (matches?.included)!
                {
                    
                    print(match.attributes.first_name + ":" + match.attributes.last_name)
                }
            }
           /*  if ( email.CreateFolder(folder_name: "new folder 2", parent_folder_id: nil) != nil)
            {
                print("successfully created folder")
            }*/
            
            var results : Folder.result? = nil
            results = email.GetFolders()
            
           
           /* let m : Message.ComposeResult? = email.ComposeMessage(recpt_ids: [email.GetProfile().id!], body: "hello3", subject: "test", reply_to_id: "", urgent: false)
            
            if (m != nil)
            {
                print("Sent message")
                email.SaveDraft(Msg: m!) //save draft
                
            }*/
            
            
            
            //email.GetBroadcasts()
            
            if (results != nil)
            {
                
                
                for mail in (results?.data)!
                {
                   // print(mail.attributes.name + ":" + mail.id) //inbox == 647, trash 650
                    
                   
                    
                    
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
                
                /*var info : [Email.sender_information]
                info = email.GetToInformation(messages: Messages!, msg_id: Message.id)
                
                for person in info {
                    print(person.first_name! + ":" + person.last_name!)
                }*/
                
                let msg = email.GetMessage(folder_id: String(Message.attributes.folder_id), message_id: Message.id)
                
                if (msg != nil)
                {
                let info = email.GetToInformation(Message: msg!)
                    
                    for person in info {
                        print(person.first_name! + ":" + person.last_name! + ":" + (msg?.data.id)!)
                        
                    }
                   
                  
                   /* print( email.MoveMessages(from_folder: String((msg?.data.attributes.folder_id)!), to_folder: "648", message_ids: [(msg?.data.id)!]))*/
                   
                    
                    //print(msg?.data.attributes.body)
                    
                    //email.GetSenderInformation(Message: msg!)
                    
                    
                    
                    
                }
                
            }
        }
    }
    
    
}


