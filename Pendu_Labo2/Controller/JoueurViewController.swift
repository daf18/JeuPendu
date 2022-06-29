//
//  JoueurViewController.swift
//  Pendu_Labo2
//
//  Created by MAC on 2022-05-29.
//

import UIKit
import CoreData

class JoueurViewController: UIViewController {

    var score = 0
    var jeuId = 0 //2
    var nom = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Joueur]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        nomTextField.delegate = self
        pointsLabel.text = "Points: \(score)"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false

            view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.nom = nomTextField.text!
        print("dismiss keyboard")
        print(self.nom)
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear called in ViewConroller")
    }
    
    @IBOutlet weak var nomTextField: UITextField!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        nomTextField.resignFirstResponder()
    }
    
    @IBAction func validateBtn(_ sender: UIButton) {
        
        if(self.nom == ""){
            let alert = UIAlertController(title: "🕵️ Vous êtes dans le top 5 des héros de tous les temps", message: "Veuillez entrer votre nom!", preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else {
            //Create a Joueur object
            let newJoueur = Joueur(context: self.context)
            newJoueur.nom=self.nom
            newJoueur.jeuId = Int16(self.jeuId)
            newJoueur.stats = Int32(self.score)
            
            //Save the data
            do {
                try self.context.save()
            }
            catch{
                
            }
            dismiss(animated: false, completion: nil)
            print("saved")
        }
    }
}

extension JoueurViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) ->
    UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDuration: 3.5, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDuration: 3.5, animationType: .dismiss)
    }
}

extension JoueurViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.nom = nomTextField.text!
        print("return pressed keyboard")
        print(self.nom)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.4,animations: {
            self.view.frame.origin.y = -100
        })
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2,animations: {
            self.view.frame.origin.y = 0
        })
    }
}
