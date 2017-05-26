//
//  ViewController.swift
//  Trending Apps
//
//  Created by milan on 01/05/17.
//  Copyright © 2017 apps. All rights reserved.
//


/****************************************
 
 The soul purpose of this repository is to learn basic syntax of Swift 3, getting familiar with UITableViews, JSON parsing and Aysn Image downloads.
 
 Please do not consider this repo as the learning resource, as there may or may not be some code that should not be written as it should be. This may misguide you and you run too far on wrong way due to this project.
 
 ****************************************
 */

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var tblAppsListView:UITableView!
    var arrAppsList : Array<Any> = []

    //MARK: View Delegate Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callAPITrendingAppsList()
        
        tblAppsListView.rowHeight = UITableViewAutomaticDimension
    }
    
    //MARK:Network Requests
    
    func callAPITrendingAppsList() {
        
        let reqUrlString = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topfreeapplications/limit=25/json"
        
        let url = URL(string: reqUrlString)

        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try? JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String: Any]
                    
                    let dicFeed = json??["feed"] as? [String: Any]

                    self.arrAppsList = (dicFeed?["entry"] as? [Any])!

                    OperationQueue.main.addOperation({
                        self.tblAppsListView.reloadData()
                    })

                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
    
    //MARK: Memory Warning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAppsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "AppListCell")

        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "AppListCell")
        }

        let dicCell = self.arrAppsList[indexPath.row] as? [String: Any]

        let title = dicCell?["title"] as? [String:String]
        
        let arrUrl = dicCell?["im:image"] as? [Any]
        
        let url = arrUrl?[0] as? [String:Any]
        
        let urlString = url?["label"] as? String
        
        cell?.imageView?.backgroundColor = UIColor.red
        cell?.imageView?.image = UIImage(named:"app.jpg")
        cell?.imageView?.downloadFrom(link: urlString, contentMode: UIViewContentMode.center)
        cell?.textLabel?.text = title?["label"]

        return cell!
    }
}

extension UIImageView
{
    func downloadFrom(link:String?, contentMode mode: UIViewContentMode)
    {
        contentMode = mode
        if link == nil
        {
            self.image = UIImage(named: "app.jpg")
            return
        }
        if let url = NSURL(string: link!)
        {
            print("\nstart download: \(url.lastPathComponent!)")
            URLSession.shared.dataTask(with: NSURL(string: link!)! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    let image = UIImage(data: data!)
                    self.image = image
                    self.layoutSubviews()
                })

            }).resume()
        }
        else
        {
            self.image = UIImage(named: "default")
        }
    }
}
