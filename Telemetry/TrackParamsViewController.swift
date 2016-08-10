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

class TrackParamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let OPEN_TRACK_SEGUE_IDENTIFIER = "openTrack"
    
    let HEADER_CELL_IDENTIFIER = "headerCell"
    let DATE_CELL_IDENTIFIER = "pickerCell"
    let START_DATE_CELL_IDENTIFIER = "startDateCell"
    let END_DATE_CELL_IDENTIFIER = "endDateCell"
    
    let kDatePickerTag = 12345
    let kPickerHeight = 196.0
    var datePickerIndexPath: NSIndexPath?
    
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
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if(identifier == OPEN_TRACK_SEGUE_IDENTIFIER){
            if(trackParams.startDate == nil || trackParams.endDate == nil){
                self.showAlert("Ошибка", msg: "Укажите период")
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destVC = segue.destinationViewController as? TrackViewController{
            destVC.autoId = self.autoId
            destVC.trackParams = self.trackParams
        }
    }
    
    //MARK: UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.indexPathHasPicker(indexPath)){
            if let cell = tableView.dequeueReusableCellWithIdentifier(DATE_CELL_IDENTIFIER) as? DateCell{
                
                return cell
            }
        } else {
            switch(indexPath.row){
            case kHeaderCellRow:
                if let cell = tableView.dequeueReusableCellWithIdentifier(HEADER_CELL_IDENTIFIER) as? CommonCell{
                    cell.mainText.text = "ВЫБЕРИТЕ ПЕРИОД ДЛЯ ТРЕКА"
                    return cell
                }
                break
            case kDateStartRow:
                if let cell = tableView.dequeueReusableCellWithIdentifier(START_DATE_CELL_IDENTIFIER) as? DateCell{
                    return cell
                }
                break
            case kDateEndRow:
                if let cell = tableView.dequeueReusableCellWithIdentifier(END_DATE_CELL_IDENTIFIER) as? DateCell{
                    return cell
                }
                break
            default:
                break
            }
        }

        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            if (cell.reuseIdentifier! == START_DATE_CELL_IDENTIFIER || cell.reuseIdentifier! == END_DATE_CELL_IDENTIFIER){
                self.displayInlineDatePickerForRowAtIndexPath(indexPath)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.hasInlineDatePicker()){
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(self.indexPathHasPicker(indexPath)){
            return CGFloat(kPickerHeight)
        } else {
            return self.table.rowHeight
        }
    }
    
    //MARK: -Alerts
    
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //MARK: IBActions
    @IBAction func dateAction(sender: UIDatePicker){
        if let datePickerIP = self.datePickerIndexPath{
            let targetedCellIndexPath = NSIndexPath(forRow: datePickerIP.row - 1, inSection: 0)
            if let cell = self.table.cellForRowAtIndexPath(targetedCellIndexPath) as? DateCell{
                if(cell.reuseIdentifier! == START_DATE_CELL_IDENTIFIER){
                     self.trackParams.startDate = Int64(sender.date.timeIntervalSince1970)
                } else if(cell.reuseIdentifier! == END_DATE_CELL_IDENTIFIER){
                    self.trackParams.endDate = Int64(sender.date.timeIntervalSince1970)
                }
                cell.dateLabel.text = sender.date.toPickerString().uppercaseString
            }
        }
    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    //MARK: UIPicker
    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
     
     @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
     */
    
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool{
        
        var targetedRow = indexPath.row
        targetedRow += 1
        
        let checkDatePickerCell = self.table.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: 0))
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
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool{
        return (self.hasInlineDatePicker() == true && (self.datePickerIndexPath?.row == indexPath.row))
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath){
        // display the date picker inline with the table content
        self.table.beginUpdates()
        
        var before = false //indicates if the date picker is below "indexPath", help us determine which row to reveal
        
        if(self.hasInlineDatePicker()){
            before = self.datePickerIndexPath?.row < indexPath.row
        }
        
        var sameCellClicked = false
        if let pickerIndexPath = self.datePickerIndexPath{
            sameCellClicked = (pickerIndexPath.row - 1 == indexPath.row)
        }
        
        // remove any date picker cell if it exists
        if(self.hasInlineDatePicker()){
            self.table.deleteRowsAtIndexPaths([NSIndexPath(forRow: (self.datePickerIndexPath?.row)!, inSection: 0)], withRowAnimation: .Fade)
            self.datePickerIndexPath = nil
        }
        
        if(!sameCellClicked){
            // hide the old date picker and display the new one
            var rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            var indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            
            self.toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            self.datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        // always deselect the row containing the start or end date
        
        self.table.deselectRowAtIndexPath(indexPath, animated: true)
        self.table.endUpdates()
        
        //UPDATE DATE PICKER
        self.updateDatePicker()
    }
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath){
        self.table.beginUpdates()
        
        let ip = NSIndexPath(forRow: indexPath.row + 1, inSection: 0)
        // check if 'indexPath' has an attached date picker below it
        if(self.hasPickerForIndexPath(indexPath)){
            self.table.deleteRowsAtIndexPaths([ip], withRowAnimation: .Fade)
        } else {
            self.table.insertRowsAtIndexPaths([ip], withRowAnimation: .Fade)
        }
        
        self.table.endUpdates()
    }
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
     */
    func updateDatePicker(){
        if(self.datePickerIndexPath != nil){
            let associatedDatePickerCell = self.table.cellForRowAtIndexPath(self.datePickerIndexPath!)
            
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
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool{
        var hasDate = false
        
        if(indexPath.row == kDateStartRow || indexPath.row == kDateEndRow || (self.hasInlineDatePicker() && indexPath.row == kDateEndRow + 1)){
            hasDate = true
        }
        
        return hasDate
    }
    
    //MARK: DateCellProtocol
    func dateTableCellProtocolDateChanged(date: NSDate?) {
        
    }

}
