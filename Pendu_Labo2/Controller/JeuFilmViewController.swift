//
//  JeuFilmViewController.swift
//  Pendu_Labo2
//
//  Created by MAC on 2022-05-25.
//

import UIKit
import GameKit
import AVFoundation
import CoreData

class JeuFilmViewController: UIViewController {

    @IBOutlet weak var hangmanImgView: UIImageView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var guessesRemainingLabel: UILabel!
    @IBOutlet weak var filmTitleLabel: UILabel!
    
    var lettersPressedBtnArray: [UIButton] = []
    
    var filmTitle = ""
    var filmTitleLettersArray = [Character]()
    var filmLanguage = ""
    var filemRated = ""
    
    var hiddenfilmTitle = ""
    var hiddenFilmTitleArray = [Character]()
    var numberOfLetters = 0
    
    var flag4 = 0
    var flag2 = 0
    var flag1 = 0
    
    var letterTapped: Character = "."
    
    var filmReleased = ""
    var filmRating = ""
    var filmGenre = ""
    var filmDirectors=""
    var filmActors=""
    
    var state: State = .ongoing
    enum State {
        case ongoing, over
    }
    
    var userTries = 6 {
        didSet {
            guessesRemainingLabel.text = "\(userTries) essais restants"
        }
    }
    
    var hangmanImgNumber = 0 {
        
        didSet {
            hangmanImgView.image = UIImage(named: "film-hangman\(hangmanImgNumber)")
        }
    }
    
    var score = 0 {
        didSet {
            if score > 1 {
                scoreLabel.text = "Score \(score)"
            } else {
                scoreLabel.text = "Score \(score)"
            }
        }
    }
    
    let jeuId = 2
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items: [Joueur]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Piste", style: .plain, target: self, action: #selector(giveClue))
        resetGame()
    }
    
    @objc func giveClue() {
//        print("lives left: \(String(describing: userTries))")
        
        var message = ""
        if(userTries == 4 || userTries == 3){
            message = "Ce film est sorti en: " + self.filmReleased
//            print(">>>>>>>>>>>>>userTries == 3/4 \(message)")
        }else if(userTries == 2){
            message = "Ce film est sorti en " + self.filmReleased + "\n Le genre de ce film est: " + self.filmGenre + "\n" + self.filmRating
//            print(">>>>>>>>>>>>>userTries == 2 \(message)")
        }else if(userTries == 1){
            message = "Ce film est sorti en " + self.filmReleased + "\n Le genre de ce film est: " + self.filmGenre + "\n" + self.filmRating + "\n Directeurs: " + self.filmDirectors + "\n Acteurs: " + self.filmActors
//            print(">>>>>>>>>>>>>userTries == 1 \(message)")
        }else {
            message = "S'il vous plaît, faites un essai!"
        }
        // create the alert
        let alert = UIAlertController(title: "🕵️ Tips", message: message, preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func letterTapped(_ sender: UIButton) {
 
        if(Character(sender.currentTitle!) == "_"){
            letterTapped = Character(" ")
        }else{
            letterTapped = Character(sender.currentTitle!)
        }
        
        lettersPressedBtnArray.append(sender)
        //desabaling the button
        sender.isEnabled = false
        
        //changing the text color of the letter on the button
        sender.setTitleColor(UIColor(red: 164/255, green: 108/255, blue: 157/255, alpha: 1), for: UIControl.State.disabled) // sa fac o functie pt refresh?
        findFilm(char: letterTapped)
        
        if(userTries == 4 && flag4 == 0) {
            flag4 += 4
            giveClue()
        }
        if(userTries == 2 && flag2 == 0) {
            flag2 += 2
            giveClue()
        }
        if(userTries == 1 && flag1 == 0) {
            flag1 += 1
            giveClue()
        }
    }
    
    func findFilm(char: Character) {
        
        if userTries > 0 {
            if filmTitle.contains(char) {
                score += 1
                let indices = filmTitleLettersArray.allIndices(of: char)
                
                for i in 0..<indices.count{
                    hiddenFilmTitleArray[indices[i]] = char
                }
                if String(hiddenFilmTitleArray) == filmTitle {
                    score += 1
                    winingAlert()
                }
                filmTitleLabel.text = String(hiddenFilmTitleArray)
            }else {
                hangmanImgNumber += 1
                userTries -= 1
                if userTries == 0 {losingAlert()}
            }
        }
    }
    
    func getFilm() {
        //Fulfill the id to 5 char
        let randomId = String(format: "%0.5d", Int.random(in: 1..<55253))
        FilmService.shared.getFilm(randomId: randomId) { success, myFilm in
            guard let unFilm = myFilm?.Title.uppercased(), success == true else {
                self.presentAlert()
                return
            }
            print(">>>>>>>>>>>>\(unFilm)<<<<<<<<<<<<")
            if(myFilm!.Rated == "N/A" || myFilm!.Ratings.isEmpty){  //myFilm!.Language != "English" || 
                self.resetGame()
            }else{
                let rateNote = "IMDB Note: " + myFilm!.Ratings[0].Value
                self.filmReleased = myFilm!.Released
                self.filmTitle = unFilm
                self.filmGenre = myFilm!.Genre
                self.filmRating =  rateNote
                self.filmDirectors = self.getLimitedPeople(filmPosition: myFilm!.Director, limitedNo: 2)
                self.filmActors = self.getLimitedPeople(filmPosition: myFilm!.Actors, limitedNo: 3)
                
                self.loadScreen(filmTitle: unFilm)
            }
        }
        
    }
    
    private func getLimitedPeople(filmPosition: String, limitedNo: Int) -> String{
        var newString = ""
        let arr = filmPosition.split(separator: ",")
        if(arr.count > limitedNo){
            newString = arr[0..<limitedNo].joined(separator: ",")
        }else{
            newString = arr.joined(separator: ",")
        }
        return newString
    }
    
    private func presentAlert(){
        let alertVC = UIAlertController(title: "Error", message: "The word download failed", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func loadScreen(filmTitle: String) {
        //breaking array into characters
        filmTitleLettersArray = Array(filmTitle)
        //counting the filmTitle's letters
        numberOfLetters = filmTitleLettersArray.count
        //setting the filmTitleLabel to match the number of chars in the film to be guessed
        
        //filmTitleLabel.text = filmTitle.pregReplace(pattern: "[a-zA-Z]", with: "*")
        
        filmTitleLabel.text = String(repeating: "*", count: numberOfLetters)
        //array of film to be guessed chars
        hiddenFilmTitleArray = [Character](repeating: "*", count: numberOfLetters)
    }
    
    func resetGame() {
        filmTitle = ""
        filmTitleLettersArray = [Character]()
        
        hiddenfilmTitle = ""
        hiddenFilmTitleArray = [Character]()
        numberOfLetters = 0
        
        flag4 = 0
        flag2 = 0
        flag1 = 0
    
        userTries = 6
        hangmanImgNumber = 0
        if(state == .over){
            score = 0
        }
        
        guessesRemainingLabel.text = "\(userTries) essais restants"
        scoreLabel.text = "Score \(score)"
        hangmanImgView.image = UIImage(named: "film-hangman\(hangmanImgNumber)")
        
        getFilm()
        resetButtons(buttons: (lettersPressedBtnArray))
        print(lettersPressedBtnArray as Any)
    }
    
    private func resetButtons(buttons: [UIButton]){
        for btn in buttons {
            btn.isEnabled = true
            btn.setTitleColor(UIColor(red: 184/255, green: 216/255, blue: 239/255, alpha: 1), for: UIControl.State.normal)
        }
    }
    
    private func winingAlert(){
        let alertVC = UIAlertController(title: "🏆", message: "Vouz avez gagné le jeu", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Rejouer", style: .default, handler: { action in
            self.state = .ongoing
            self.resetGame()
        })) //new game
        present(alertVC, animated: true, completion: nil)
    }
    
    private func losingAlert(){
        let alertVC = UIAlertController(title: "💥", message: "Désolé! Vouz avez perdu!", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Rejouer", style: .default, handler: { action in
            self.state = .over
            
            //Judge if need to popup nom input
            var stateLengthFilm = 0
            var fifthStatFilm = 0
            
    //        print(">>>>>>>>>>>>>>>>>>>\(StatsSingleton.shared.stateLengthFilm)")
    //        print(">>>>>>>>>>>>>>>>>>>\(StatsSingleton.shared.fifthStateFilm)")
            do {
                let request = Joueur.fetchRequest() as NSFetchRequest<Joueur>
                
                //filter jeu as Film Pendu
                let pred = NSPredicate(format: "jeuId == 2")
                request.predicate=pred
                
                //sort data desc by stats
                let sort = NSSortDescriptor(key: "stats", ascending: false)
                request.sortDescriptors = [sort]
                
                self.items = try self.context.fetch(request)
                
                if(self.items?.count ?? 0 >= 5){
                    stateLengthFilm = 5
                    fifthStatFilm = Int(self.items?[4].stats ?? 0)
                    
                }else{
                    stateLengthFilm = self.items?.count ?? 0
                    fifthStatFilm = 0
                    print(">>>>>>>> <5 \(fifthStatFilm)")
                }
            }
            catch {
                print("Fetch Joueur Error")
            }
            
            //TODO: Animation not working 
            
            guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "JoueurViewController") as? JoueurViewController else  {
                return
            }
            destinationVC.score = self.score
            destinationVC.jeuId = self.jeuId
            
            if( self.score > fifthStatFilm){
                self.present(destinationVC, animated: false, completion: nil)
                self.resetGame()
            }else{
                self.resetGame()
            }
        }))
        present(alertVC, animated: true, completion: nil)
    }
}

extension String {
    //return count
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
     
    //use regrex to replace
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
}
