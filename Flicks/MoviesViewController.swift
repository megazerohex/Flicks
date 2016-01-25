//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Jamel Peralta Coss on 1/18/16.
//  Copyright © 2016 Jamel Peralta Coss. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //instance variables
    var movies: [NSDictionary] = []
    var filterMovies: [NSDictionary] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //To connect the variable tableView with the delagate methods and DataSource
        tableView.delegate = self
        searchBar.delegate = self
        tableView.dataSource = self
        
        //CONNECT to the API
        networkRequest()
        
        // Initialize a UIRefreshControl ------> thats the circle for loading and refreshing the app
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //This method declare how many row the tableview will have
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return filterMovies.count
    }
    
    //This method is for putting content in the tableview
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        //creates an array of the different contents
        let movie = filterMovies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as? String   //for images
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
        let posterUrl = NSURL(string: posterBaseUrl + posterPath!)
        
        //This print each value of an array in the rows
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(posterUrl!)
        
        return cell
        
    }
    
    //Method for refreching
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // Make network request to fetch latest data
        //Connect to the API
        networkRequest()
        
        // Do the following when the network request comes back successfully:
        // Update tableView data source
        refreshControl.endRefreshing()
    }
    
    //Method for searchBar
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filterMovies = self.movies
        } else {
            self.filterMovies = movies.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    //If the Data is similar to what your are searching, put it in the array
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        return  true
                    }
                    //If not, pass
                    else{
                        return false
                    }
                }
                return false
            })
        }
        tableView.reloadData()
    }
    
    //method for requesting Network Data from API
    func networkRequest(){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)  //This begins the loading (MBProgressHUB)
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)  //This ends the loading (MBProgressHUB)
                if let data = dataOrNil {
                    //responseDictionary Basically is an array that contains all the data from the API
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            //this will assign all the array of data to the instance variable
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            //this one will copy all the data to a filtered one(for use of the searchbar)
                            self.filterMovies = self.movies
                            
                            //reload data after using the API
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    }
    
    //When you tap the screen the keyboard will disappear
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    
}
