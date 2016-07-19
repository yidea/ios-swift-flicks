//
//  ViewController.swift
//  flicks
//
//  Created by Yi Cao on 7/14/16.
//  Copyright © 2016 yidea. All rights reserved.
//

import UIKit
import AFNetworking

private let CELL_NAME = "com.flicks.movieCell"
private let API_BOX_OFFICE = "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
private let API_DVD = "https://api.themoviedb.org/3/movie/top_rated?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchBarDelegate {
    var movies:NSArray?
    var filtered:NSArray? //store the filtered data
    //if user doing search, table view loads from filtered. otherwise from movies
    var searchActive : Bool = false
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var networkErrBg: UIView!
    @IBOutlet weak var movieList: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up events delegate
        //otherwise didSelectRowAtIndexPath won't work
        movieList.delegate = self
        tabBar.delegate = self
        searchBar.delegate = self
        
        //default the first tab to be selected
        tabBar.selectedItem = tabBar.items!.first as UITabBarItem?
        
        //hide movieList at beginning
        movieList.hidden = true
        
        //only make request if search bar has no item inside (when user come back from movie detail)
        if !searchActive {
            makeRequest(){};
        }
        
        self.initPullToRefresh()
    }
    
    /**
     * add the refresh control as a subview of the scrollview.
     * It's best to insert it at the lowest index so that it appears behind all the views in the scrollview.
     */
    func initPullToRefresh(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        movieList.insertSubview(refreshControl, atIndex: 0)
    }
    
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag != tabBar.selectedItem?.tag {
            return
        }
        //if a new tab is clicked, refetch
        makeRequest(){}
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText=="" {
            filtered = movies
            searchActive = false;
        }else{
            
            let resultPredicate = NSPredicate(format: "title contains[c] %@", searchText)
            filtered = movies!.filteredArrayUsingPredicate(resultPredicate)
            searchActive = true;
        }
        movieList.reloadData()
    }
    
    
    func onRefresh() {
        //get current selected tag
        makeRequest(){
            self.refreshControl.endRefreshing()
        };
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filtered?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_NAME) as! MovieCell;
        let movie = self.filtered![indexPath.row] as! NSDictionary
        
        // fill cell
        cell.movieTitle.text = movie["title"] as? String
        cell.movieDescription.text = movie["overview"] as? String
        cell.movieImage.alpha = 0.5
        
        // grab image url
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        cell.movieImage.setImageWithURL(imageUrl!)
        //let imgUrl = NSURL(string: movie.valueForKeyPath("poster_path") as! String)!
        //cell.movieImage.setImageWithURL(imgUrl)
        
        // fadein the high res image
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            cell.movieImage.alpha = 1.0
            }, completion: nil)
        return cell;
    }
    
    
    //deselect table if table is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        view.endEditing(true)
    }
    
    
    func makeRequest(closure:()->()){
        //switch api based on current selected tab
        var currentAPI:String
        if tabBar.selectedItem?.tag == 0 {
            currentAPI = API_BOX_OFFICE
        }else{
            currentAPI = API_DVD
        }
        //every request hide the network error notification
        self.networkErrBg.hidden = true;
        
        //making request
        // let request = NSURLRequest(URL: NSURL(string:currentAPI)! )
        let request = NSURLRequest(URL: NSURL(string:currentAPI)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval:5)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if (error) != nil {
                //if there is network error, show it up
                dispatch_async(dispatch_get_main_queue()){
                    self.networkErrBg.hidden = false;
                    self.activityIndicator.hidden = true
                }
            }
            //even if there is network error, the following line would load the data from cache and show some data
            let dictionary = (try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? NSDictionary
            dispatch_async(dispatch_get_main_queue()) {
                //if successful show movie list container
                self.movieList.hidden = false
                self.activityIndicator.hidden = true
                //need to check if dictionary exist! otherwise the following won't pass compile
                if let dictionary = dictionary {
                    self.movies = dictionary["results"] as? NSArray
                    self.filtered = dictionary["results"] as? NSArray
                    self.movieList.reloadData()
                }
                closure()
            }
            
        }
        task.resume()
    }
    
    /**
     * do a little preparation before navigation
     * pass movie object from this view controller to detail view controller
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        let cell = sender as! UITableViewCell
        let indexPath = movieList.indexPathForCell(cell)!
        let movie = filtered![indexPath.row] as! NSDictionary
        let transitionToController = segue.destinationViewController as! MovieDetailViewController
        // Pass the selected object to the new view controller.
        transitionToController.movie = movie
        view.endEditing(true)
    }
    
    /**
     * when tap anywhere on the screen, cancel the number pad triggered by input
     * TODO: come up with a better approach
     * ? this is deprecating the events for push navigation if i add the tapgesture reference outlet connection to view
     */
    @IBAction func onTapAnywhere(sender: UITapGestureRecognizer) {
        NSLog("onTap")
        //view.endEditing(true)
    }
    
}
