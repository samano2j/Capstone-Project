//
//  MailDetailsTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-01-31.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class MailDetailsTableViewController: UITableViewController {
    
    //var details = []
    var details: [String: String] = ["from":"", "to":"", "subject":"", "date":"", "body":""]
    // Outlets
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bodyCell: UITableViewCell!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func compose(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "composeViewController") as? ComposeViewController
        
        let modal = controller
        let transitionDelegate = SPStorkTransitioningDelegate()
        modal?.transitioningDelegate = transitionDelegate
        modal?.modalPresentationStyle = .custom
        self.present(modal!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        getCustomImage(imageDisplayName: fromLabel.text, imageView: imageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func configureView() {
        fromLabel.text = details["from"]
        toLabel.text = details["to"]
        subjectLabel.text = details["subject"]
        dateLabel.text = details["date"]
        bodyLabel.text = "Recently, a transdiagnostic ICBT program for depression and anxiety (the Wellbeing Course) was tailored specifically to post-secondary students (the UniWellbeing Course). The UniWellbeing Course has now been offered to over 800 students. In its current format, the UniWellbeing Course consists of 4 core lessons with the first three lessons having homework assignments. Students also have access to case stories and additional resources as needed (e.g., resources related . In order to facilitate treatment completion, students receive automated emails and have brief weekly contact with a clinician via email or phone. Results are highly encouraging, with 63% of students completing the full course, 11% 3 out of 4 lessons, 13% 2 lessons and 13% 1 lesson. Significant improvements in anxiety and depression have been found along with high levels of satisfaction with the course. It has been identified that prior to treatment, it is critical for students to be introduced to the course, comfortable with the treatment approach, and willing to practice and develop skills.Recently, a transdiagnostic ICBT program for depression and anxiety (the Wellbeing Course) was tailored specifically to post-secondary students (the UniWellbeing Course). The UniWellbeing Course has now been offered to over 800 students. In its current format, the UniWellbeing Course consists of 4 core lessons with the first three lessons having homework assignments. Students also have access to case stories and additional resources as needed (e.g., resources related . In order to facilitate treatment completion, students receive automated emails and have brief weekly contact with a clinician via email or phone. Results are highly encouraging, with 63% of students completing the full course, 11% 3 out of 4 lessons, 13% 2 lessons and 13% 1 lesson. Significant improvements in anxiety and depression have been found along with high levels of satisfaction with the course. It has been identified that prior to treatment, it is critical for students to be introduced to the course, comfortable with the treatment approach, and willing to practice and develop skills.Recently, a transdiagnostic ICBT program for depression and anxiety (the Wellbeing Course) was tailored specifically to post-secondary students (the UniWellbeing Course). The UniWellbeing Course has now been offered to over 800 students. In its current format, the UniWellbeing Course consists of 4 core lessons with the first three lessons having homework assignments. Students also have access to case stories and additional resources as needed (e.g., resources related . In order to facilitate treatment completion, students receive automated emails and have brief weekly contact with a clinician via email or phone. Results are highly encouraging, with 63% of students completing the full course, 11% 3 out of 4 lessons, 13% 2 lessons and 13% 1 lesson. Significant improvements in anxiety and depression have been found along with high levels of satisfaction with the course. It has been identified that prior to treatment, it is critical for students to be introduced to the course, comfortable with the treatment approach, and willing to practice and develop skills.Recently, a transdiagnostic ICBT program for depression and anxiety (the Wellbeing Course) was tailored specifically to post-secondary students (the UniWellbeing Course). The UniWellbeing Course has now been offered to over 800 students. In its current format, the UniWellbeing Course consists of 4 core lessons with the first three lessons having homework assignments. Students also have access to case stories and additional resources as needed (e.g., resources related . In order to facilitate treatment completion, students receive automated emails and have brief weekly contact with a clinician via email or phone. Results are highly encouraging, with 63% of students completing the full course, 11% 3 out of 4 lessons, 13% 2 lessons and 13% 1 lesson. Significant improvements in anxiety and depression have been found along with high levels of satisfaction with the course. It has been identified that prior to treatment, it is critical for students to be introduced to the course, comfortable with the treatment approach, and willing to practice and develop skills.Recently, a transdiagnostic ICBT program for depression and anxiety (the Wellbeing Course) was tailored specifically to post-secondary students (the UniWellbeing Course). The UniWellbeing Course has now been offered to over 800 students. In its current format, the UniWellbeing Course consists of 4 core lessons with the first three lessons having homework assignments. Students also have access to case stories and additional resources as needed (e.g., resources related . In order to facilitate treatment completion, students receive automated emails and have brief weekly contact with a clinician via email or phone. Results are highly encouraging, with 63% of students completing the full course, 11% 3 out of 4 lessons, 13% 2 lessons and 13% 1 lesson. Significant improvements in anxiety and depression have been found along with high levels of satisfaction with the course. It has been identified that prior to treatment, it is critical for students to be introduced to the course, comfortable with the treatment approach, and willing to practice and develop skills.Recently, a transdiagnostic ICBT program for depression and anxiety (the Wellbeing Course) was tailored specifically to post-secondary students (the UniWellbeing Course). The UniWellbeing Course has now been offered to over 800 students. In its current format, the UniWellbeing Course consists of 4 core lessons with the first three lessons having homework assignments. Students also have access to case stories and additional resources as needed (e.g., resources related . In order to facilitate treatment completion, students receive automated emails and have brief weekly contact with a clinician via email or phone. Results are highly encouraging, with 63% of students completing the full course, 11% 3 out of 4 lessons, 13% 2 lessons and 13% 1 lesson. Significant improvements in anxiety and depression have been found along with high levels of satisfaction with the course. It has been identified that prior to treatment, it is critical for students to be introduced to the course, comfortable with the treatment approach, and willing to practice and develop skills.Recently, a transdiagnostic ICBT program for depression and anxiety (the Wellbeing Course) was tailored specifically to post-secondary students (the UniWellbeing Course). The UniWellbeing Course has now been offered to over 800 students. In its current format, the UniWellbeing Course consists of 4 core lessons with the first three lessons having homework assignments. Students also have access to case stories and additional resources as needed (e.g., resources related . In order to facilitate treatment completion, students receive automated emails and have brief weekly contact with a clinician via email or phone. Results are highly encouraging, with 63% of students completing the full course, 11% 3 out of 4 lessons, 13% 2 lessons and 13% 1 lesson. Significant improvements in anxiety and depression have been found along with high levels of satisfaction with the course. It has been identified that prior to treatment, it is critical for students to be introduced to the course, comfortable with the treatment approach, and willing to practice and develop skills.Recently, a transdiagnostic ICBT program for depression and anxiety (the Wellbeing Course) was tailored specifically to post-secondary students (the UniWellbeing Course). The UniWellbeing Course has now been offered to over 800 students. In its current format, the UniWellbeing Course consists of 4 core lessons with the first three lessons having homework assignments. Students also have access to case stories and additional resources as needed (e.g., resources related . In order to facilitate treatment completion, students receive automated emails and have brief weekly contact with a clinician via email or phone. Results are highly encouraging, with 63% of students completing the full course, 11% 3 out of 4 lessons, 13% 2 lessons and 13% 1 lesson. Significant improvements in anxiety and depression have been found along with high levels of satisfaction with the course. It has been identified that prior to treatment, it is critical for students to be introduced to the course, comfortable with the treatment approach, and willing to practice and develop skills."//details["body"]
    }
    
    func getCustomImage(imageDisplayName: String?, imageView: UIImageView!){
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: UIColor.colorHash(name: name), circular: true, stroke: true)
        } else {
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        if (indexPath.section == 0 && indexPath.row == 2) {
            let maxLabelSize = CGSize(width: bodyLabel.frame.width, height: .greatestFiniteMagnitude)
            let actualLabelSize = bodyLabel.text!.boundingRect(with: maxLabelSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: bodyLabel.font], context: nil).height
        
            let labelHeight = actualLabelSize
            height = labelHeight 
            bodyCell.separatorInset = UIEdgeInsets(top: 0, left: bodyCell.bounds.size.width, bottom: 0, right: 0)
        }
        else if (indexPath.section == 0 && indexPath.row == 1) {
            let maxLabelSize = CGSize(width: subjectLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)
            let actualLabelSize = subjectLabel.text!.boundingRect(with: maxLabelSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: subjectLabel.font], context: nil).height
            let dateActualLabelSize = dateLabel.text!.boundingRect(with: maxLabelSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: dateLabel.font], context: nil).height
            let labelHeight = actualLabelSize
            height = labelHeight + dateActualLabelSize + 20
        }
        else {
            height = 67.0
        }
        return height
    }
}


