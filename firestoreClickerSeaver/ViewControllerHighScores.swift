//
//  ViewControllerHighScores.swift
//  firestoreClickerSeaver
//
//  Created by Brian Seaver on 3/28/22.
//

import UIKit

class ViewControllerHighScores: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    var highScores : [Int] = []

    @IBOutlet weak var tableViewOutlet: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
        if indexPath.row < highScores.count{
            cell.textLabel?.text = "\((indexPath.row + 1))) \(highScores[indexPath.row]) points"
        }
        else{
            cell.textLabel?.text = "\((indexPath.row + 1)))"
        }
        return cell
    }


}
