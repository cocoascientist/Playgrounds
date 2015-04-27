//: # Table Views
//:
//: Let's implement the basic logic necessary to display a table view. Typically this would be done with a `UIViewController` but using a Playground works just fine too.

//: First import `UIKit`

import UIKit

//: Phase struct

struct Phase {
    let name: String
    let image: UIImage
}

//: View Model

struct PhaseViewModel {
    private let phase: Phase
    
    init(phase: Phase) {
        self.phase = phase
    }
    
    func configureCell(cell: UITableViewCell) -> Void {
        cell.textLabel?.text = self.phase.name
        cell.imageView?.image = self.phase.image
    }
}

//: Table view data source

class PhasesDataSource: NSObject, UITableViewDataSource {
    private let phases: [Phase] = [
        Phase(name: "Full Moon", image: UIImage(named: "full.png")!),
        Phase(name: "Last Quarter", image: UIImage(named: "third.png")!),
        Phase(name: "New Moon", image: UIImage(named: "new.png")!),
        Phase(name: "First Quarter", image: UIImage(named: "first.png")!)
    ]
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.phases.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        let phase = phases[indexPath.row]
        let viewModel = PhaseViewModel(phase: phase)
        
        viewModel.configureCell(cell)
        
        return cell
    }
}

let tableView = UITableView(frame: CGRectMake(0, 0, 320, 480), style: .Plain)

let dataSource = PhasesDataSource()
tableView.dataSource = dataSource

tableView.reloadData()
