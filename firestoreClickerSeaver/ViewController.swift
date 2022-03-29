//
//  ViewController.swift
//  firestoreClickerSeaver
//
//  Created by Brian Seaver on 3/27/22.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

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
    var players : [Player] = []
    var dataArray : [Data] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        //Reading data from file
        clickButtonOutlet.isEnabled = false
        addListener()
        addListenerPlayer()
        readScores()
        readPlayers(completionHandler: printPlayers)
//        {
//            print("completion handler for readPlayers")
//            self.printPlayers()
//
//        }
        
        scoreLabel.text = "\(score)"
        timeLabel.text = "\(time)"
    }
    
    func printPlayers()-> Void{
                    for player in players {
                        print("\(player.name) \(player.score)")
                    }
        tableViewOutlet.reloadData()
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
    
    func addListenerPlayer(){
        print("Heard Player change")
        database.collection("playerObjects")
            .addSnapshotListener { documentsSnapshot, error in
              guard let document = documentsSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
                self.readPlayers {
                    
                }
//                print("hear this many document changes \(document.documentChanges.count)")
//                //print(document.documents[0].documentID)
//                for change in document.documentChanges{
//                    if change.type == .added{
//                        do {
//                            self.players.append(try document.documents[0].data(as: Player.self))
//                            print("added a player that changed")
//                        } catch {
//                        print(error)
//                        }
//
//                    }
//                }
//              guard let data = document.data() else {
//                print("Document data was empty.")
//                return
//              }
//                self.highScores = data["highScores"] as! [Int]
//                self.highScores.sort()
//                self.highScores.reverse()
//                self.tableViewOutlet.reloadData()
//                self.updateHighScoresVC()
//              print("High Scores Changed")
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
    
  
    
    func readPlayers(completionHandler: @escaping() -> Void){
        
        database.collection("playerObjects").getDocuments { (snapshot, error) in
          
            if let error = error {
            print(error)
          } else if let snapshot = snapshot {
              print("got snapshot")
              self.players = snapshot.documents.compactMap { (document) -> Player? in
                  print("getting a player")
                var x: Player? = nil
                  do {
                    x = try document.data(as: Player.self)
                  } catch {
                  print(error)
                  }
                  //print("\(x?.name) \(x?.score)")
                return x
                }
              
              }
            self.players.sort(by: {$0.score > $1.score})
            self.printPlayers()
            //completionHandler()
        }
      
          
       

        
//        let db = database.collection("playerObjects").getDocuments { (snapshot, error) in
//         print("getting player documents")
//            if let error = error {
//            print(error)
//          } else if let snapshot = snapshot {
//              print("got the snapshot")
//              self.players = snapshot.documents.compactMap {
//                  print("getting a player")
//
//              var x = try? $0.data(as: Player.self)
//                  print(x?.name)
//                  return x
//
//            }
//
//          }
//
//        }
        
        
        
        
    
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
            

           
            // write to firestore as array
            // can't read data in firestore
//            do{
//                let encoder = JSONEncoder()
//                let data = try encoder.encode(player)
//                dataArray.append(data)
//                docRef.setData(["array": dataArray], merge: true)
//            }
//            catch{
//                    print("Error saving player")
//                }
                var name = ""
            let alert = UIAlertController(title: "Top 10 High Score!", message: "Enter your name", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
                name = alert.textFields![0].text!
                var player = Player(name: name, score: self.score)
                self.players.append(player)
                
                //write Custom object to firebase as separate document
                let objRef = self.database.collection("playerObjects")
                       do{
                           try objRef.document().setData(from: player)
                       }catch{
                           print("L firmly grasp it L")
                       }
                self.players.sort(by: {$0.score > $1.score})
                self.tableViewOutlet.reloadData()
            }))
            present(alert, animated: true, completion: nil)
            
            

                
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
        //highScores.count
        players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
        //cell.textLabel?.text = "\((indexPath.row + 1))) \(highScores[indexPath.row]) points"
        cell.textLabel?.text = players[indexPath.row].name
        cell.detailTextLabel?.text = "\(players[indexPath.row].score)"
        return cell
    }
    
   
}

