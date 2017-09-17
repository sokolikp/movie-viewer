//
//  DetailsViewController.swift
//  MovieViewer
//
//  Created by Paul Sokolik on 9/14/17.
//  Copyright © 2017 Paul Sokolik. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    var movieImage: UIImage!
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        titleLabel.text = movie["title"] as? String
        descriptionLabel.text = movie["overview"] as? String
        descriptionLabel.sizeToFit()
        
        // properly display release date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let releaseDateStr = movie["release_date"] as? String
        let date = dateFormatter.date(from: releaseDateStr!)
        dateFormatter.dateFormat = "MMMM yyyy"
        dateLabel.text = dateFormatter.string(from: date!)
        
        let rating = movie["vote_average"] as! NSNumber
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        ratingLabel.text = numberFormatter.string(from: rating)
        ratingLabel.layer.masksToBounds = true
        ratingLabel.layer.cornerRadius = 5
        
        infoView.frame.size.height = max(descriptionLabel.frame.size.height + (descriptionLabel.frame.origin.y - infoView.frame.origin.y) + 10, infoView.frame.size.height)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.size.height)
        
        self.posterView.image = self.movieImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
