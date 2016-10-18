//
//  TrackParamsViewController.swift
//  Telemetry
//
//  Created by IMAC  on 10.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class TrackParamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let OPEN_TRACK_SEGUE_IDENTIFIER = "openTrack"
    
    let HEADER_CELL_IDENTIFIER = "headerCell"
    let DATE_CELL_IDENTIFIER = "pickerCell"
    let START_DATE_CELL_IDENTIFIER = "startDateCell"
    let END_DATE_CELL_IDENTIFIER = "endDateCell"
    
    let kDatePickerTag = 12345
    let kPickerHeight = 196.0
    var datePickerIndexPath: IndexPath?
    
    let kHeaderCellRow = 0
    let kDateStartRow = 1
    let kDateEndRow = 2

    @IBOutlet var table: UITableView!
    
    var autoId: Int64?
    
    var trackParams: (startDate: Int64?, endDate: Int64?) = (nil, nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Segues
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(identifier == OPEN_TRACK_SEGUE_IDENTIFIER){
            if(trackParams.startDate == nil || trackParams.endDate == nil){
                self.showAlert("Ошибка", msg: "Укажите период")
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? TrackViewController{
            destVC.autoId = self.autoId
            destVC.trackParams = self.trackParams
        }
    }
    
    //MARK: UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.indexPathHasPicker(indexPath)){
            if let cell = tableView.dequeueReusableCell(withIdentifier: DATE_CELL_IDENTIFIER) as? DateCell{
                
                return cell
            }
        } else {
            switch((indexPath as NSIndexPath).row){
            case kHeaderCellRow:
                if let cell = tableView.dequeueReusableCell(withIdentifier: HEADER_CELL_IDENTIFIER) as? CommonCell{
                    cell.mainText.text = "ВЫБЕРИТЕ ПЕРИОД ДЛЯ ТРЕКА"
                    return cell
                }
                break
            case kDateStartRow:
                if let cell = tableView.dequeueReusableCell(withIdentifier: START_DATE_CELL_IDENTIFIER) as? DateCell{
                    return cell
                }
                break
            case kDateEndRow:
                if let cell = tableView.dequeueReusableCell(withIdentifier: END_DATE_CELL_IDENTIFIER) as? DateCell{
                    return cell
                }
                break
            default:
                break
            }
        }

        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if (cell.reuseIdentifier! == START_DATE_CELL_IDENTIFIER || cell.reuseIdentifier! == END_DATE_CELL_IDENTIFIER){
                self.displayInlineDatePickerForRowAtIndexPath(indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.hasInlineDatePicker()){
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(self.indexPathHasPicker(indexPath)){
            return CGFloat(kPickerHeight)
        } else {
            return self.table.rowHeight
        }
    }
    
    //MARK: -Alerts
    
    func showAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: IBActions
    @IBAction func dateAction(_ sender: UIDatePicker){
        if let datePickerIP = self.datePickerIndexPath{
            let targetedCellIndexPath = IndexPath(row: (datePickerIP as NSIndexPath).row - 1, section: 0)
            if let cell = self.table.cellForRow(at: targetedCellIndexPath) as? DateCell{
                if(cell.reuseIdentifier! == START_DATE_CELL_IDENTIFIER){
                     self.trackParams.startDate = Int64(sender.date.timeIntervalSince1970)
                } else if(cell.reuseIdentifier! == END_DATE_CELL_IDENTIFIER){
                    self.trackParams.endDate = Int64(sender.date.timeIntervalSince1970)
                }
                cell.dateLabel.text = sender.date.toPickerString().uppercased()
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    
    //MARK: UIPicker
    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
     
     @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
     */
    
    func hasPickerForIndexPath(_ indexPath: IndexPath) -> Bool{
        
        var targetedRow = (indexPath as NSIndexPath).row
        targetedRow += 1
        
        let checkDatePickerCell = self.table.cellForRow(at: IndexPath(row: targetedRow, section: 0))
        if let _ = checkDatePickerCell?.viewWithTag(kDatePickerTag){
            return true
        } else {
            return false
        }
    }
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
     */
    func hasInlineDatePicker() -> Bool{
        return (self.datePickerIndexPath != nil)
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
     
     @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
     */
    func indexPathHasPicker(_ indexPath: IndexPath) -> Bool{
        return (self.hasInlineDatePicker() == true && ((self.datePickerIndexPath as NSIndexPath?)?.row == (indexPath as NSIndexPath).row))
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func displayInlineDatePickerForRowAtIndexPath(_ indexPath: IndexPath){
        // display the date picker inline with the table content
        self.table.beginUpdates()
        
        var before = false //indicates if the date picker is below "indexPath", help us determine which row to reveal
        
        if(self.hasInlineDatePicker()){
            before = (self.datePickerIndexPath as NSIndexPath?)?.row < (indexPath as NSIndexPath).row
        }
        
        var sameCellClicked = false
        if let pickerIndexPath = self.datePickerIndexPath{
            sameCellClicked = ((pickerIndexPath as NSIndexPath).row - 1 == (indexPath as NSIndexPath).row)
        }
        
        // remove any date picker cell if it exists
        if(self.hasInlineDatePicker()){
            self.table.deleteRows(at: [IndexPath(row: ((self.datePickerIndexPath as NSIndexPath?)?.row)!, section: 0)], with: .fade)
            self.datePickerIndexPath = nil
        }
        
        if(!sameCellClicked){
            // hide the old date picker and display the new one
            let rowToReveal = (before ? (indexPath as NSIndexPath).row - 1 : (indexPath as NSIndexPath).row)
            let indexPathToReveal = IndexPath(row: rowToReveal, section: 0)
            
            self.toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            self.datePickerIndexPath = IndexPath(row: (indexPathToReveal as NSIndexPath).row + 1, section: 0)
        }
        // always deselect the row containing the start or end date
        
        self.table.deselectRow(at: indexPath, animated: true)
        self.table.endUpdates()
        
        //UPDATE DATE PICKER
        self.updateDatePicker()
    }
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func toggleDatePickerForSelectedIndexPath(_ indexPath: IndexPath){
        self.table.beginUpdates()
        
        let ip = IndexPath(row: (indexPath as NSIndexPath).row + 1, section: 0)
        // check if 'indexPath' has an attached date picker below it
        if(self.hasPickerForIndexPath(indexPath)){
            self.table.deleteRows(at: [ip], with: .fade)
        } else {
            self.table.insertRows(at: [ip], with: .fade)
        }
        
        self.table.endUpdates()
    }
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
     */
    func updateDatePicker(){
        if(self.datePickerIndexPath != nil){
            let associatedDatePickerCell = self.table.cellForRow(at: self.datePickerIndexPath!)
            
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as? UIDatePicker{
                
//                var saved: String?
//                
//                if(associatedDatePickerCell?.reuseIdentifier == END_DATE_CELL_IDENTIFIER){
//                    saved = APP.i().filterManager?.filter.endSaved
//                } else if(associatedDatePickerCell?.reuseIdentifier == START_DATE_CELL_IDENTIFIER){
//                    saved = APP.i().filterManager?.filter.startSaved
//                }
//                
//                if let s = saved{
//                    if let interval = Double(s){
//                        targetedDatePicker.setDate(NSDate(timeIntervalSince1970: interval), animated: true)
//                    }
//                } else {
//                    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
//                    let comp = calendar?.components([NSCalendarUnit.Year,NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: NSDate())
//                    let newdate = calendar?.dateFromComponents(comp!)
//                    print(newdate?.toString())
//                    targetedDatePicker.setDate(newdate!, animated: false)
//                }
            }
        }
    }
    
    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
     
     @param indexPath The indexPath to check if it represents start/end date cell.
     */
    func indexPathHasDate(_ indexPath: IndexPath) -> Bool{
        var hasDate = false
        
        if((indexPath as NSIndexPath).row == kDateStartRow || (indexPath as NSIndexPath).row == kDateEndRow || (self.hasInlineDatePicker() && (indexPath as NSIndexPath).row == kDateEndRow + 1)){
            hasDate = true
        }
        
        return hasDate
    }
    
    //MARK: DateCellProtocol
    func dateTableCellProtocolDateChanged(_ date: Date?) {
        
    }

}
