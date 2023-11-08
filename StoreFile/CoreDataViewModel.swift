//
//  CoreDataViewModel.swift
//  StoreFile
//
//  Created by Rana Ayman on 06/11/2023.
//

import Foundation
import CoreData


class CoreDataViewModel : ObservableObject {

    let container: NSPersistentContainer
    @Published var savedEntity : FileEntity?
    @Published var showAlert = false
    @Published var customFileName: String = ""
    @Published var isGmailSelected: Bool = false
    @Published var isOutlookSelected: Bool = false
    
    init(){
        container = NSPersistentContainer(name: "FileModel")
        container.loadPersistentStores { description, error in
            if let error  = error {
                print("Error loading core data \(error)")
            } else {
                print("Successfully loaded core data.")

            }
        }
       getFileData()
    }


    func getFileData() {
        let request  = NSFetchRequest<FileEntity>(entityName: "FileEntity")
        do {
            savedEntity = try container.viewContext.fetch(request).first
            objectWillChange.send()
            print(savedEntity?.loginResponse ?? "")
        } catch let error {
            print("Error fetching. \(error)")
        }
    }

    func addNewFileData(text: String) {
        savedEntity?.loginResponse = text
        showAlert = true
        saveTextToFile(text: text)
        saveData()
    }

    func deleteFileData(indexSet : IndexSet){
        guard indexSet.first != nil else { return }
        container.viewContext.delete(savedEntity!)
        saveData()

    }


    func saveData(){
        do {
           try container.viewContext.save()
        } catch  let error {
            print("Error saving. \(error)")
        }
    }

    func saveTextToFile(text: String) {
           if customFileName.isEmpty {
               customFileName = "TestFile.txt"
           }

           if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
               let fileURL = dir.appendingPathComponent(customFileName)
               do {
                   try text.write(to: fileURL, atomically: true, encoding: .utf8)
               } catch {
                   print("Error saving file: \(error.localizedDescription)")
               }
           }
       }
}
