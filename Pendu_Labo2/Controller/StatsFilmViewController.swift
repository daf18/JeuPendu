//
//  StatsFilmViewController.swift
//  Pendu_Labo2
//
//  Created by MAC on 2022-05-25.
//

import UIKit
import CoreData

class StatsFilmViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items: [Joueur]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        fetchPeople()
    }

    func fetchPeople() {
        do {
            let request = Joueur.fetchRequest() as NSFetchRequest<Joueur>
            
            //filter jeu as Film Pendu
            let pred = NSPredicate(format: "jeuId == 2")
            request.predicate=pred
            
            //sort data desc by stats
            let sort = NSSortDescriptor(key: "stats", ascending: false)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            if(self.items?.count ?? 0 >= 1){
                StatsSingleton.shared.stateLengthFilm = 1
                StatsSingleton.shared.fifthStateFilm = Int(self.items?[0].stats ?? 0)
            }else{
                StatsSingleton.shared.stateLengthFilm = self.items?.count ?? 0
                StatsSingleton.shared.fifthStateFilm = 0
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        catch {
            print("Fetch Joueur Error")
        }
    }
}

extension StatsFilmViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return the number of Joueur Film
        var lengtth = 0
        if(self.items?.count ?? 0 < 5){
            lengtth = self.items?.count ?? 0
        } else {
            lengtth = 5
        }
        return lengtth
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "JoueurCell", for: indexPath)
        
        //Get Joueur from array and set the label
        let joueur = self.items![indexPath.row]
        
        cell.textLabel?.text = joueur.nom
        cell.detailTextLabel?.text = "Points: \(joueur.stats)"
        
        return cell
    }
}
