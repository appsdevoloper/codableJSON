//
//  ViewController.swift
//  CodableJSON
//
//  Created by Apple on 15/08/19.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

struct Root : Decodable {
    let status : Bool
    let sections : [Section]
    
    private enum CodingKeys : String, CodingKey { case status, data }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Bool.self, forKey: .status)
        let data = try container.decode([String:[Result]].self, forKey: .data)
        sections = data.map{ Section(title: $0.key, result: $0.value) }
    }
}

struct Section {
    let title : String
    var result : [Result]
}

struct Result : Decodable {
    let id, name, date : String
    let group : [String]
}

class MyCustomCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
   
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UIBarButtonItem!
    let cellReuseIdentifier = "cell"
    var sections = [Section]()
    var filteredSections = [Section]()
    var searchController : UISearchController!
    var isFiltering = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = 66.0
        self.loadJSON()
    }
    
    // MARK: JSON Data Load
    
    func loadJSON(){
        let urlPath = ""
        let url = NSURL(string: urlPath)
        let session = URLSession.shared
        let task = session.dataTask(with: url! as URL) { data, response, error in
            guard data != nil && error == nil else {
                print(error!.localizedDescription)
                return
            }
            do {
                let decoder = try JSONDecoder().decode(Root.self,  from: data!)
                let status = decoder.status
                
                if status == true {
                    self.sections = decoder.sections
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    
                }
            } catch { print(error) }
        }
        task.resume()
    }
    
    // MARK: UITableview Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering ? filteredSections.count : sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = isFiltering ? filteredSections[section] : sections[section]
        return currentSection.result.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isFiltering ? filteredSections[section].title : sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! MyCustomCell
        let section = isFiltering ? filteredSections[indexPath.section] : sections[indexPath.section]
        let item = section.result[indexPath.row]
        cell.nameLabel.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You tapped cell number \(indexPath.row).")
        let section = isFiltering ? filteredSections[indexPath.section] : sections[indexPath.section]
        let item = section.result[indexPath.row]
        print("\(item)")
    }
    
    // MARK: UISearchBar Delegates
    
    @IBAction func searchAction(_ sender: Any) {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.keyboardType = UIKeyboardType.asciiCapable
        searchController.searchBar.barTintColor = #colorLiteral(red: 0.317096545, green: 0.5791940689, blue: 0.3803742655, alpha: 1)
        searchController.searchBar.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        searchController.dimsBackgroundDuringPresentation = false
        
        // Make this class the delegate and present the search
        self.searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isFiltering = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        filteredSections.removeAll()
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isFiltering = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filteredSections = sections.compactMap { section -> Section? in
                let filteredContent = section.result.filter {$0.name.range(of: searchText, options: .caseInsensitive) != nil }
                return filteredContent.isEmpty ? nil : Section(title: section.title, result: filteredContent)
            }
            isFiltering = true
        } else {
            filteredSections.removeAll()
            isFiltering = false
        }
        self.tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
