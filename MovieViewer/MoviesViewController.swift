 //
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Paul Sokolik on 9/12/17.
//  Copyright © 2017 Paul Sokolik. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var isSearching: Bool = false
    var endpoint: String!
    
    override func viewWillAppear(_ animated: Bool) {
        // hide networking error by default
        networkErrorView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        movieSearchBar.delegate = self
        
        loadData(refreshControl, showInitialLoadSpinner: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredMovies = movies?.filter({ (movie) -> Bool in
            let title = movie["title"] as! String
            
            return title.lowercased().contains(searchText.lowercased())
        })

        if(searchText.isEmpty){
            isSearching = false;
        } else {
            isSearching = true;
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            if isSearching {
                return filteredMovies!.count
            } else {
                return movies.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = isSearching ? filteredMovies![indexPath.row] : movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let fullDate = movie["release_date"] as! String
        let index = fullDate.index(fullDate.startIndex, offsetBy: 4)
        let year = fullDate.substring(to: index)
        let rating = movie["vote_average"] as! NSNumber
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.yearLabel.text = year
        cell.ratingLabel.text = String(describing: rating)
        cell.ratingLabel.layer.masksToBounds = true
        cell.ratingLabel.layer.cornerRadius = 5
        
        // try to set movie poster image
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = URL(string: baseUrl + posterPath)
            cell.posterImageView.setImageWith(imageUrl!)
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! DetailsViewController
        let cell = sender as! MovieCell
        let cellIndex = tableView.indexPath(for: cell)?.row
        let movie = movies![cellIndex!]
        
        destinationViewController.movie = movie
        
        // send image separately for convenience
        destinationViewController.movieImage = cell.posterImageView.image
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadData(refreshControl, showInitialLoadSpinner: false)
    }

    func loadData (_ refreshControl: UIRefreshControl, showInitialLoadSpinner: Bool) {
        
        // hide networking error by default
        self.networkErrorView.isHidden = true
        
        let API_KEY = "f136cf23b2e84e57530d037c649ca5c4"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(API_KEY)")
        var request = URLRequest(url: url!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        // Display HUD right before the request is made
        if showInitialLoadSpinner {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler:
        { (dataOrNil, response, error) in
            if let data = dataOrNil {
                
                let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                self.movies = dictionary["results"] as? [NSDictionary]
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                if (showInitialLoadSpinner) {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            } else {
                // error loading - show networking error
                print("error!")
                MBProgressHUD.hide(for: self.view, animated: true)
                self.networkErrorView.isHidden = false
            }
        });
        task.resume()
    }

}
