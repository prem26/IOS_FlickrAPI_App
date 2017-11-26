//
//  CustomTableViewController.swift
//  FlickrImageApplication
//
//  Created by Herath Mudiyanselage Nethanjan Danindu Premaratne on 13/11/17.
//  Copyright © 2017 Herath Mudiyanselage Nethanjan Danindu Premaratne. All rights reserved.
//

import UIKit
import CoreData

class CustomTableViewController: UITableViewController,UISearchBarDelegate {

    //Outlets for TableView
    @IBOutlet weak var searchView: UISearchBar!
    
    @IBOutlet weak var Customtable: UITableView!
    
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let del = UIApplication.shared.delegate as! AppDelegate
        let context = del.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Picture")
        searchView.delegate = self
        
        request.returnsObjectsAsFaults = false;
        
        do{
            let results = try context.fetch(request)
            if results.count > 0
            {
                data = results as! [NSManagedObject]
                print(data.count)
            }
        }
        catch
        {
            print("Error")
        }


    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

//    override func numberOfSections(in tableView: UITableView) -> Int {
//    
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return data.count
    }
    
    // Function for tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        // Connect the table view details with table identification and Table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ImageTableViewCell
        cell.titleLabel.text = data[indexPath.row].value(forKey: "title") as? String
        cell.descriptionLabel.text = data[indexPath.row].value(forKey: "descrip") as? String

        let image = data[indexPath.row].value(forKey: "image") as! NSData
        
        let img = UIImage(data: image as Data)
        cell.imgView.image = img
        return cell;
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.isEmpty {
            let del = UIApplication.shared.delegate as! AppDelegate
            let context = del.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Picture")
            
            request.returnsObjectsAsFaults = false;
            
            do{
                let results = try context.fetch(request)
                if results.count > 0
                {
                    data = results as! [NSManagedObject]
                }else{
                    data.removeAll()
                }
            }
            catch
            {
                print("Error")
            }
            
        }else{
            let del = UIApplication.shared.delegate as! AppDelegate
            let context = del.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Picture")
            
            // Search for Title
            let predicateTitle = NSPredicate(format: "title contains %@", searchText)
            
            // Search for Description 
            let predicateDescription = NSPredicate(format: "descrip contains %@", searchText)
            
        
            // compundPredicate hold all the predicates that needs to be search
            let compundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [predicateTitle,predicateDescription])
            
            request.predicate = compundPredicate
            
            request.returnsObjectsAsFaults = false;
            
            do{
                let results = try context.fetch(request)
                if results.count > 0
                {
                    data = results as! [NSManagedObject]
                }
            }
            catch
            {
                print("Error")
            }
            
        }
        Customtable.reloadData()
    }



   
}
