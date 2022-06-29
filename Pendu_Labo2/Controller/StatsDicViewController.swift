//
//  StatsDicViewController.swift
//  Pendu_Labo2
//
//  Created by MAC on 2022-05-25.
//

import UIKit
import CoreData

class StatsDicViewController: UIViewController {
    
    @IBOutlet weak var tableViewDictionary: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Joueur]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewDictionary.dataSource = self
        tableViewDictionary.delegate = self
        tableViewDictionary.reloadData()
        
        fetchPlayers()
    }
    func fetchPlayers() {
        do {
            let request = Joueur.fetchRequest() as NSFetchRequest<Joueur>
            
            //filter game as Dictionarygame lost
            let pred = NSPredicate(format: "jeuId == 1")
            request.predicate=pred
            
            //sort data desc by stats
            let sort = NSSortDescriptor(key: "stats", ascending: false)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            if(self.items?.count ?? 0 >= 1){
                StatsSingleton.shared.stateLengthDictionaire = 1
                StatsSingleton.shared.fifthStateDictionaire = Int(self.items?[0].stats ?? 0)
            }else{
                StatsSingleton.shared.stateLengthDictionaire = self.items?.count ?? 0
                StatsSingleton.shared.fifthStateDictionaire = 0
            }
            
            DispatchQueue.main.async {
                self.tableViewDictionary.reloadData()
            }
            
        }
        catch {
            print("Fetch Joueur Error")
        }
    }
}
    extension StatsDicViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //Return the number of Joueur Dictionary
            var lengtth = 0
            if(self.items?.count ?? 0 < 5){
                lengtth = self.items?.count ?? 0
            } else {
                lengtth = 5
            }
            return lengtth
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
            
            //Get Joueur from array and set the label
            let joueur = self.items![indexPath.row]
            
            cell.textLabel?.text = joueur.nom
            cell.detailTextLabel?.text = "Points: \(joueur.stats)"
            
            return cell
        }
}

    
    

