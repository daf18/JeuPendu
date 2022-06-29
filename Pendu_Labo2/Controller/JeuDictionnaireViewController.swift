//
//  JeuDictionnaireViewController.swift
//  Pendu_Labo2
//
//  Created by MAC on 2022-05-25.
//

import UIKit
import GameKit
import AVFoundation
import CoreData


class JeuDictionnaireViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var penduImgView: UIImageView!
    
    @IBOutlet weak var guessRemainingLabel: UILabel!
    
    @IBOutlet weak var guessWordLabel: UILabel!
    
    @IBOutlet var lettersButtons: [UIButton]!
    var lettersPressedBtnArray: [UIButton] = []
    
    var word = ""
    var wordLettersArray = [Character]()
    
    var hiddenWord = ""
    var hiddenWordArray = [Character]()
    var numberOfLetters = 0
    var letterTapped: Character = "."
    
    var state: State = .ongoing
    enum State {
        case ongoing, over
    }
    
    var userTries = 6 {
        didSet {
            guessRemainingLabel.text = "\(userTries) essais restants"
        }
    }
    
    var penduImgNumber = 0 {
        
        didSet {
            penduImgView.image = UIImage(named: "Hangman\(penduImgNumber)")
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
    let jeuId = 1
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items: [Joueur]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newWord()
    }
    
    func newWord() {
        WordService.getWord { success, randomWord in
            guard let randomWord = randomWord?.uppercased(), success == true else {
                self.presentAlert()
                return
            }
            print(randomWord)
            self.word = randomWord
            self.loadScreen(word: randomWord)
        }
        
    }
    private func presentAlert(){
        let alertVC = UIAlertController(title: "Error", message: "The word download failed", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    
    private func loadScreen(word: String) {
        //breaking array into characters
        wordLettersArray = Array(word)
        print(wordLettersArray)
        //counting the word's letters
        numberOfLetters = wordLettersArray.count
        //setting the guessWordLabel to match the number of chars in the word to be guessed
        guessWordLabel.text = String(repeating: "*", count: numberOfLetters)
        //array of word to be guessed chars
        hiddenWordArray = [Character](repeating: "*", count: numberOfLetters)
        
    }
    
    @IBAction func letterButtonTapped(_ sender: UIButton) {
        letterTapped = Character(sender.currentTitle!)
        lettersPressedBtnArray.append(sender)
        //desabaling the button
        sender.isEnabled = false
        
        //changing the text color of the letter on the button
        sender.setTitleColor(UIColor(red: 254, green: 247, blue: 165, alpha: 0), for: UIControl.State.disabled)
        findWord(char: letterTapped)
    }
    
    func findWord(char: Character) {
        
        if userTries > 0 {
            
            if word.contains(char) {
                score += 1 // add to the score indices.count ??
                let indices = wordLettersArray.allIndices(of: char)
                
                for i in 0..<indices.count{
                    hiddenWordArray[indices[i]] = char
                }
                if String(hiddenWordArray) == word {
                    score += 1
                    winingAlert()
                }
                guessWordLabel.text = String(hiddenWordArray)
                
            }else {
                
                penduImgNumber += 1
                userTries -= 1
                if userTries == 0 {losingAlert()}
            }
        }
    }
    
    func resetGame() {
        word = ""
        wordLettersArray = [Character]() 
        
        hiddenWord = ""
        hiddenWordArray = [Character]()
        numberOfLetters = 0
        
        userTries = 6
        penduImgNumber = 0
        if(state == .over){
            score = 0
        }
        
        guessRemainingLabel.text = "\(userTries) essais restants"
        scoreLabel.text = "Score \(score)"
        penduImgView.image = UIImage(named: "Hangman\(penduImgNumber)")
        
        newWord()
        resetButtons(buttons: (lettersPressedBtnArray))
        //print(lettersPressedBtnArray as Any)
    }
    
    private func resetButtons(buttons: [UIButton]){
        for btn in buttons {
            btn.isEnabled = true
            btn.setTitleColor(UIColor(red: 74/255, green: 52/255, blue: 138/255, alpha: 1), for: UIControl.State.normal)
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
    
            var stateLengthDictionaire = 0
            var fifthStateDictionaire = 0
            
            do {
                let request = Joueur.fetchRequest() as NSFetchRequest<Joueur>
                
                //filter jeu as Dictionnaire Pendu
                let pred = NSPredicate(format: "jeuId == 1")
                request.predicate=pred
                
                //sort data desc by stats
                let sort = NSSortDescriptor(key: "stats", ascending: false)
                request.sortDescriptors = [sort]
                
                self.items = try self.context.fetch(request)
                
                if(self.items?.count ?? 0 >= 5){
                    stateLengthDictionaire = 5
                    fifthStateDictionaire = Int(self.items?[4].stats ?? 0)
                    
                }else{
                    stateLengthDictionaire = self.items?.count ?? 0
                    fifthStateDictionaire = 0
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
            
            if( self.score > fifthStateDictionaire){
                self.present(destinationVC, animated: false, completion: nil)
                self.resetGame()
            }else{
                self.resetGame()
            }
        })) //new game
        present(alertVC, animated: true, completion: nil)
    }
}// end of class

// returs an array of all indexes where a character appears in the word
extension Collection where Element : Equatable {
    func allIndices(of target:Element) -> [Int] {
        let indices = self.enumerated().reduce(into: [Int]()) {
            if $1.1 == target {$0.append($1.0)}
        }
        return indices
    }
}
