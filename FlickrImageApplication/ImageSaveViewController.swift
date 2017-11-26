//
//  ImageSaveViewController.swift
//  FlickrImageApplication
//
//  Created by Herath Mudiyanselage Nethanjan Danindu Premaratne on 13/11/17.
//  Copyright © 2017 Herath Mudiyanselage Nethanjan Danindu Premaratne. All rights reserved.
//

import UIKit
import CoreData

class ImageSaveViewController: UIViewController, UINavigationControllerDelegate
{

    @IBOutlet weak var CustomImageVIew: UIImageView!
    @IBOutlet weak var TitleView: UITextField!
    @IBOutlet weak var DescriptionView: UITextField!
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function for pick the photo
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        CustomImageVIew.image = image
        dismiss(animated: false, completion: nil)
    }
    
    //Action button for search photos by keyword
    @IBAction func buttonSearchOne(_ sender: Any) {
        
        let text = keyword.text!
        
        //replace the charcters with flickr API reference
        let replace = text.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ",", with: "%2C").replacingOccurrences(of: "?", with: "%3F")
    
        
        let urlname = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=606d28710c14361545a74be26a61e24a&text=\(replace)&extras=url_m&format=json&nojsoncallback=1"
        
        
        let apiurl = URL(string: urlname)
        let request = URLRequest(url: apiurl!)
        
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler:
        {
            
            (data, response,error) in
            if(error == nil)
            {
                
                
                let jsonData = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                
                let photos = jsonData["photos"] as! [String:AnyObject]
                let libraryphotos = photos["photo"] as! [[String:AnyObject]]
                
                
                 //validation for wrong data
                if(libraryphotos.count < 1){
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Sorry", message: "No Data from Flickr ! Please Try With Another Keyword", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            NSLog("The \"OK\" alert occured.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    let random = Int(arc4random_uniform(UInt32(libraryphotos.count)))
                    
                    let randomURL = libraryphotos[random]["url_m"] as! String
                    
                    let imgURL = URL(string: randomURL)
                    
                    DispatchQueue.main.async {
                        let imgdata = try! Data(contentsOf: imgURL!)
                        let image = UIImage(data: imgdata)
                        self.CustomImageVIew.image = image
                    }
                    
                    print(randomURL)
                }
            }
        })
        task.resume();
        
    }

    //Action button for search photos by Longitude and Latitude
    @IBAction func buttonSearchTwo(_ sender: Any) {
        
        // Text Fields for longitude and latitude
       let bboxLon = Double("\(longitudeTextField.text!)")!
       let bboxLat = Double("\(latitudeTextField.text!)")!
    
        // Validation longitude and latitude
        let minimumLongitude = max((bboxLon - 1), -180)
        let maximumLongitude = min((bboxLon + 1), 180)
        let minimumLatitude = max((bboxLat - 1), -90)
        let maximumLatitude = min((bboxLat + 1), 90)
        
       let bbox = "\(minimumLongitude),\(minimumLatitude),\(maximumLongitude),\(maximumLatitude)"
        

        let urlname = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=606d28710c14361545a74be26a61e24a&bbox=\(bbox)&extras=url_m&format=json&nojsoncallback=1"
        
        let apiurl = URL(string: urlname)
        let request = URLRequest(url: apiurl!)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler:
        {
            
            (data, response,error) in
            if(error == nil)
            {
                
                
                let jsonData = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                
                let photos = jsonData["photos"] as! [String:AnyObject]
                let libraryphotos = photos["photo"] as! [[String:AnyObject]]
                
                //validation for wrong data
                if(libraryphotos.count < 1){
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Sorry ", message: "No Data from Flickr ! Please Try With Another Data ", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            NSLog("The \"OK\" alert occured.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    let random = Int(arc4random_uniform(UInt32(libraryphotos.count)))
                    
                    let randomURL = libraryphotos[random]["url_m"] as! String
                    
                    let imgURL = URL(string: randomURL)
                    
                    DispatchQueue.main.async {
                        let imgdata = try! Data(contentsOf: imgURL!)
                        let image = UIImage(data: imgdata)
                        self.CustomImageVIew.image = image
                    }
                    
                    print(randomURL)
                }
            }
        })
        task.resume()
        
    }
    
    
    // action button for save data to the database
    @IBAction func SaveButton(_ sender: Any) {
      
        //validation for empty fields
        if(TitleView.text!.isEmpty || DescriptionView.text!.isEmpty){
            
            let alert = UIAlertController(title: "Error", message: "Please Fill The Title and Description Fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
        }else{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Picture", into: context)
            
            entity.setValue(TitleView.text, forKey: "title")
            entity.setValue(DescriptionView.text, forKey: "descrip")
            
            let image = UIImageJPEGRepresentation(CustomImageVIew.image!, 1)
            
            // Save value getting from ImageUploadView in date coloum in database
            entity.setValue(image, forKey: "image")
            
            
            do{
                try context.save()
                print("Done")
                // alert to inform user, success of the submission
                let alert = UIAlertController(title: "Cogratulations", message: "Successfully Updated the Database", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            catch
            {
                print("Enter")
                //alert user to error of submission
                let alert = UIAlertController(title: "Sorry", message: "Error While Updating Database", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
      
        
    }

}
