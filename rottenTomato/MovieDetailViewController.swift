//
//  MovieDetailViewController.swift
//  flicks
//
//  Created by Yi Cao on 7/14/16.
//  Copyright © 2016 yidea. All rights reserved.
//


import UIKit

class MovieDetailViewController: UIViewController {
    var movie: NSDictionary!
    
    @IBOutlet weak var movieNavTitle: UINavigationItem!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var pgTag: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var rating: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialize with the movie passed from movies view controller
        movieImage.alpha = 0.5
        movieTitle.text = movie["title"] as? String
        movieNavTitle.title = movie["title"] as? String
        desc.text = movie["overview"] as? String
        pgTag.text = movie["release_date"] as? String
        rating.text = movie["vote_average"] as? String
        
        //enable scroller
        scroller.scrollEnabled = true;
        scroller.contentSize = CGSizeMake(320, 624);
        
        self.loadMovieImage()
    }
    
    /**
     * load low res image first
     * when high res available it overrides the low res image
     * set up image fadein
    */
    func loadMovieImage(){
        //use low res image first
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        movieImage.setImageWithURL(imageUrl!)
        
        
        //fadein the image
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.movieImage.alpha = 1.0
            }, completion: nil)
    }
    
}
