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

    var movieImage: UIImage!
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        self.titleLabel.text = self.movie["title"] as? String
        self.descriptionLabel.text = self.movie["overview"] as? String
        self.descriptionLabel.sizeToFit()
        self.posterView.image = self.movieImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
