//
//  MyTableViewController.swift
//  Timetunnel
//
//  Created by kobe on 2017/10/7.
//  Copyright © 2017年 kobe. All rights reserved.
//

import UIKit
import Gallery
import Lightbox
import AVFoundation
import AVKit
import SVProgressHUD
import Photos

class MyTableViewController: UITableViewController, LightboxControllerDismissalDelegate, GalleryControllerDelegate {

    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
    
    var tableData:[CellData]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

         Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        
        if let _tableData  = CellData.readAllCellDataFromFile() {
            
            tableData = _tableData
        }
        else {
            print("opps, tableData is nil, new it")
            self.tableData = [CellData]()
        }
        
        //test
        let myCustomView = UIImageView()
        let myImage: UIImage = #imageLiteral(resourceName: "kobe")
        myCustomView.image = myImage
        
        //let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        
        //test
        tableView.tableHeaderView = myCustomView
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (tableData?.count) ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRow at index=\(indexPath.row)")
        
        let cellData = tableData![indexPath.row]
        
        
        let photosCount = cellData.photos.count
        //let cellData = tableData[indexPath.row]
        let cellID:String = (photosCount >= 3) ? CellId.Cell_3P : (photosCount == 2) ? CellId.Cell_2P : CellId.Cell_1P
        print("cellForRow at (\(indexPath.row), photoCount=\(photosCount), cellID=\(cellID)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MyTableViewCell

        
        
        // Configure the cell...
        configureCell(cell: cell, photosCount: photosCount, cellData: cellData)
        
        return cell
    }
    
    func fetchImageData(from photos:[PhotoInfo], complete: @escaping (Int, Data) -> Void)
    {
        let fetchOptions = PHFetchOptions()
        //fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.includeAssetSourceTypes = PHAssetSourceType(rawValue: PHAssetSourceType.typeiTunesSynced.rawValue + PHAssetSourceType.typeUserLibrary.rawValue)
        
        //setting fetch photos options
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.version = .original
        requestOptions.isNetworkAccessAllowed = true
        
        let showCount = (photos.count >= 3) ? 3 : photos.count
        
        var uuids = [String]()
        for i in 0 ... showCount-1
        {
            uuids.append(photos[i].id)
        }
        
        let photoAsset = PHAsset.fetchAssets(withLocalIdentifiers: uuids, options: fetchOptions)
        
        
        for i in 0 ... showCount-1 {
            
            PHImageManager.default().requestImageData(for: photoAsset[i], options: requestOptions, resultHandler: {(data,_,_,_) in
                
                print("request image index = \(i) done.")
                complete(i, data!)
            })
        }
    }
    
    func configureCell(cell:MyTableViewCell, photosCount:Int, cellData:CellData) {
        
        fetchImageData(from: cellData.photos, complete: { (index, data) in
            DispatchQueue.main.async {
                print("update image index =\(index) done.")
                self.updateUI(cell: cell, index: index, imageData: data, uploadTime: cellData.dateTime, cellDescription: cellData.text)
            }
        })
    }
    
    func updateUI(cell:MyTableViewCell, index:Int, imageData:Data, uploadTime:String, cellDescription:String?){
        
        DispatchQueue.main.async {
            //update label
            cell.uploadTime.text = uploadTime
            cell.detailTextLabel?.text = cellDescription ?? "no comment"
            
            //update image
            switch index {
            case 0:
                cell.imageView1.image = UIImage(data: imageData)
            case 1:
                cell.imageView2.image = UIImage(data: imageData)
            default:
                cell.imageView3.image = UIImage(data: imageData)
            }
        }
        
        
    }
    
    @IBAction func addPhotosButtonTouched(_ sender: Any) {
        gallery = GalleryController()
        gallery.delegate = self
        
        present(gallery, animated: true, completion: nil)
    }
    
    // MARK: - LightboxControllerDismissalDelegate
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
    // MARK: - GalleryControllerDelegate
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
        
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    let controller = AVPlayerViewController()
                    controller.player = AVPlayer(url: tempPath)
                    
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image])
    {
        print("select images done. count=\(images.count)")
        controller.dismiss(animated: true, completion: nil)
        
        
        var cellData = CellData()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateString = formatter.string(from: date)
        cellData.dateTime = dateString
        cellData.text = "comment @ \(dateString)"
        
        for image in images {
            
            let imageID = image.asset.localIdentifier
            let imagePath = imageID
            let photoInfo = PhotoInfo(id: imageID, path: imagePath, description: "UploadPhoto")
            
            cellData.photos.append(photoInfo)
        }
        tableData.append(cellData)
        CellData.save2File(cellDatas: tableData)
        
        tableView.reloadData()
        
        gallery = nil
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        LightboxConfig.DeleteButton.enabled = true
        
        SVProgressHUD.show()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            SVProgressHUD.dismiss()
            self?.showLightbox(images: resolvedImages.flatMap({ $0 }))
        })
    }
    
    // MARK: - Helper
    func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
            return
        }
        
        let lightboxImages = images.map({ LightboxImage(image: $0) })
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self
        
        gallery.present(lightbox, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myCustomView = UIImageView()
        let myImage: UIImage = #imageLiteral(resourceName: "kobe")
        myCustomView.image = myImage
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.addSubview(myCustomView)
        return header
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
