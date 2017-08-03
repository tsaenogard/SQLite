/*
 CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, height DOUBLE)
 INSERT INTO students (name, height) VALUES ('小米', '168')
 INSERT INTO students (name, height) VALUES ('大米', '169')
 SELECT * FROM students
 SELECT * FROM students ORDER BY height DESC
 SELECT * FROM students ORDER BY height ASC
 SELECT * FROM students WHERE height = '168'
 SELECT * FROM students WHERE name LIKE '%小%'
 UPDATE students SET name = 'John', height = '150' WHERE id = '1'
 UPDATE students SET height = '0'
 DELETE FROM students WHERE id = '2'
 DELETE FROM students
 */

import UIKit

class ViewController: UIViewController {
    
    var functionArray = [
        "建立表格",              //0
        "加入資料",              //1
        "讀取資料 - 全部 - 無排序",//2
        "讀取資料 - 全部 - DESC", //3
        "讀取資料 - 全部 - ASC",  //4
        "讀取資料 - equal",      //5
        "讀取資料 - like",       //6
        "修改資料 - 設定條件",     //7
        "修改資料 - 不設定條件",   //8
        "刪除資料 - 單筆",        //9
        "刪除資料 - 全部"         //10
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(UIView(frame: CGRect.zero))
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            print("建立表格")
        case 1:
            let rowArray = [
                ["name": "大強", "height": "174.2"],
                ["name": "小明", "height": "168.9"],
                ["name": "小花", "height": "153.2"],
                ["name": "小江", "height": "174.2"],
                ["name": "小陳", "height": "157.4"],
                ["name": "老趙", "height": "174.2"],
                ["name": "小美", "height": "160.8"]
            ]
            print("加入資料")
        case 2:
            print("讀取資料")
        case 3:
            print("讀取資料 - DESC")
        case 4:
            print("讀取資料 - ASC")
        case 5:
            print("讀取資料 - EQUAL")
        case 6:
            print("讀取資料 - LIKE")
        case 7:
            print("修改資料 - 設定條件")
        case 8:
            print("修改資料 - 無設定條件")
        case 9:
            print("刪除資料 - 單筆 - ")
        case 10:
            print("刪除資料 - 全部 - ")
        default:
            break
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.functionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellID")
        }
        cell!.textLabel?.text = self.functionArray[indexPath.row]
        return cell!
    }
    
}
