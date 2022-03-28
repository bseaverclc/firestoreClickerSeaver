//
//  ViewController.swift
//  firestoreClickerSeaver
//
//  Created by Brian Seaver on 3/27/22.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    let database = Firestore.firestore()
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var clickButtonOutlet: UIButton!
    
    @IBOutlet weak var playOutlet: UIButton!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    //declare blank timer variable
        var timer = Timer()
    var score = 0
    var time = 10
    var highScores : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        //Reading data from file
        clickButtonOutlet.isEnabled = false
        addListener()
        readScores()
        
        scoreLabel.text = "\(score)"
        timeLabel.text = "\(time)"
    }
    
    func addListener(){
        database.collection("game").document("scores")
            .addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                print("Document data was empty.")
                return
              }
                self.highScores = data["highScores"] as! [Int]
                self.highScores.sort()
                self.highScores.reverse()
                self.tableViewOutlet.reloadData()
                self.updateHighScoresVC()
              print("High Scores Changed")
            }
    }
    
    func readScores(){
        let docRef = database.document("game/scores")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else{
                return
            }
            
            print(data)
            
            guard let scores = data["highScores"] as? [Int] else{
                return
            }
            self.highScores = scores
            self.highScores.sort()
            self.highScores.reverse()
            self.tableViewOutlet.reloadData()
            self.updateHighScoresVC()
            
        }
    }

    @IBAction func clickAction(_ sender: UIButton) {
        score = score + 1
        scoreLabel.text = "\(score)"
        
    }
    
    func updateHighScoresVC(){
        var highScoresTab = self.tabBarController?.viewControllers?[1] as! ViewControllerHighScores
        highScoresTab.highScores = highScores
        if let hst = highScoresTab.tableViewOutlet{
            hst.reloadData()
        }
    }
    
   
    @objc func timerAction(){
           
        time = time - 1
        timeLabel.text = "\(time)"
        if time == 0{
            clickButtonOutlet.isEnabled = false
            timer.invalidate()
            
            let docRef = database.document("game/scores")
            
                highScores.append(score)
            highScores.sort()
                highScores.reverse()
            tableViewOutlet.reloadData()
                docRef.setData(["highScores": highScores])
            updateHighScoresVC()
                
                playOutlet.isEnabled = true
            
            
        }
        
        
        }
    
    
    @IBAction func playAgainAction(_ sender: UIButton) {
        playOutlet.isEnabled = false
        time = 10
        score = 0
        timeLabel.text = "\(time)"
        scoreLabel.text = "\(score)"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        clickButtonOutlet.isEnabled = true
       
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        highScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = "\((indexPath.row + 1))) \(highScores[indexPath.row]) points"
        return cell
    }
    
   
}

