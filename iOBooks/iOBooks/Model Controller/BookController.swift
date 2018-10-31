//
//  BookController.swift
//  iOBooks
//
//  Created by Nikita Thomas on 10/29/18.
//  Copyright © 2018 Nikita Thomas. All rights reserved.
//

import UIKit

class BookController: Codable {
    static var shared = BookController()
    private init() {}
    
    var bookSearch: BookSearch?
    var bookshelves: [Bookshelf] = []
    
    func newBook(name: String, image: String) -> Book {
        return Book(name: name, image: image, review: "", read: false)
    }
    
    func newShelf(name: String, books: [Book]) -> Bookshelf{
        let shelf = Bookshelf(name: name, books: books)
        bookshelves.append(shelf)
        return shelf
    }
    
    
    func search(term: String, completion: @escaping () -> Void = {}) {
        guard
            let baseURL = URL(string: "https://www.googleapis.com/books/v1/volumes"),
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
            else {
                fatalError("Unable to setup url and components")
        }
        
        components.queryItems = [URLQueryItem(name: "q", value: term)]
        
        guard let url = components.url else {return}
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else {
                NSLog("Could not run datatask")
                completion()
                return
            }
            
            do {
                let searchResults = try JSONDecoder().decode(BookSearch.self, from: data)
                self.bookSearch = searchResults
                completion()
                return
            } catch {
                NSLog("Could not decode JSON into BookSearch objects")
                completion()
                return
            }
        }
        dataTask.resume()
        
    }
    
    // MARK - FIREBASE
    
    // functions we need
    
    // download everything
    // download specefic book?
    // create a new book
    // update existing book
    
    var baseURL: URL = URL(string: "https://iobooks-76036.firebaseio.com/")!
    var bookShelfIdentifier: String = ""
    
    func createBookshelvesFromBooks(_ books:[Book]) {
        var shelves:[String:[Book]] = [:]
        for book in books {
            for shelf in book.bookshelves {
                if shelves[shelf]  != nil {
                    shelves[shelf]?.append(book)
                } else {
                    shelves[shelf] = [book]
                }
            }
        }
        
        
        var shelfObjects: [Bookshelf] = []
        for (shelf, books) in shelves {
            let theShelf = newShelf(name: shelf, books: books)
            shelfObjects.append(theShelf)
        }
        bookshelves = shelfObjects
    }
    
    func stubToBook(bookStubs: [BookStub]) -> [Book]{
        var books: [Book] = []
        for stub in bookStubs {
            let book = Book(name: stub.name, image: stub.image ?? "", review: stub.review, read: stub.read)
            books.append(book)
        }
        return books
    }
    
    func downloadBooks() {
        URLSession.shared.dataTask(with: baseURL) { data, _, err in
            if let err = err {
                NSLog("\(err)")
                return
            }
            
            guard let data = data else {return}
            
            do {
                let bookStubs = try JSONDecoder().decode([BookStub].self, from: data)
                let books = self.stubToBook(bookStubs: bookStubs)
                self.createBookshelvesFromBooks(books)
            } catch {
                NSLog("Couldn't decode bookStubs")
                return
            }
            }.resume()
    }
    
    
    func stubToBook(book: Book) -> BookStub {
        
        return BookStub(name: book.name, image: book.image ?? " ", review: book.review, read: book.read, bookshelves: book.bookshelves)
    }
    
    
    
    func uploadBooks(shelves: [Bookshelf], completion: @escaping (_ success: Bool) -> Void = { _ in }) {
        var bookStubArray = [BookStub]()
        for shelf in shelves {
            for book in shelf.books {
                bookStubArray.append(stubToBook(book: book))
            }
        }
        print(bookStubArray)
        var req = URLRequest(url: baseURL.appendingPathComponent("/bookStubs").appendingPathExtension("json"))
        req.httpMethod = "PUT"
        
        do {
            let jsonData = try JSONEncoder().encode(bookStubArray)
            req.httpBody = jsonData
        } catch {
            NSLog("Couldn't encode stubs into JSON: \(error)")
            completion(false)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: req) { data, _ , err in
            if let err = err {
                NSLog("error creating datatask: \(err)")
                completion(false)
                return
            }
            
            if let data = data, let utf8Rep = String(data: data, encoding: .utf8) {
                print("response: ", utf8Rep)
            } else {
                print("no readable data received as response")
            }
            
        }
        dataTask.resume()
    }
}












