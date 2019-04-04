//
//  PrintPageRenderer.swift
//  InVoice
//
//  Created by Georg Kitz on 05/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import CoreGraphics

/// Rendered PDF data structure
struct RenderedPDF {
    let data: Data
    let path: URL
    let directory: URL
}

/// Renders the html into pdf with the formatter of the webview (we need the formatter of the webview otherwise <img> tag renderings
/// don't work
class PrintPageRenderer: UIPrintPageRenderer {
    
    /// A4 size with 72dpi
    struct A4PageSize {
        static let width = 595.2
        static let height =  842.8
    }
    
    struct LetterPageSize {
        static let width = 612.0
        static let height = 792.0
    }
    
    let printRect: CGRect
    let printFormatter: UIPrintFormatter
    
    init(withFormatter formatter: UIPrintFormatter) {
        printFormatter = formatter
        printFormatter.perPageContentInsets = .zero

        // Specify the frame of the A4 page.
        if Account.current().design?.pageSize == JobPageSize.letter.rawValue {
            printRect = CGRect(x: 0.0, y: 0.0, width: LetterPageSize.width, height: LetterPageSize.height)
        } else {
            printRect = CGRect(x: 0.0, y: 0.0, width: A4PageSize.width, height: A4PageSize.height)
        }

        super.init()
        
        // Set the page frame.
        self.setValue(NSValue(cgRect: printRect), forKey: "paperRect")
        self.setValue(NSValue(cgRect: printRect), forKey: "printableRect")
    }

    /// renders the pdf
    ///
    /// - Parameters:
    ///   - directory: in which directory under `~/Documents/` do we want to store the invoice
    ///   - filename: name of the invoice
    /// - Returns: the pdf data structure
    func renderPDF(to directory: Directory, filename: String = "temp.pdf") -> RenderedPDF? {
        addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let data = NSMutableData()
        
        // to force the pdf context to obey our sizes we need to set it here
        UIGraphicsBeginPDFContextToData(data, printRect, nil)
        prepare(forDrawingPages: NSRange(location: 0, length: numberOfPages))
        
        let bounds = UIGraphicsGetPDFContextBounds()

        for page in 0..<numberOfPages {
            UIGraphicsBeginPDFPage()
            drawPage(at: page, in: bounds)
        }
        
        UIGraphicsEndPDFContext()
        
        guard let dir = FileManagerHelper.createDirectory(directory) else {
            return nil
        }
        
        let filePath = dir + filename
        FileManagerHelper.deleteFile(at: filePath)
        
        data.write(toFile: filePath, atomically: true)
        
        return RenderedPDF(data: data as Data, path: URL(fileURLWithPath: filePath), directory: URL(fileURLWithPath: dir))
    }
}

// public helper to start the renderer
func renderPDF(with formatter: UIPrintFormatter, to directory: Directory = .invoices, filename: String) -> Observable<RenderedPDF> {
    return Observable.create({ (observer) -> Disposable in
        
            let renderer = PrintPageRenderer(withFormatter: formatter)
            if let pdf = renderer.renderPDF(to: directory, filename: filename) {
                observer.onNext(pdf)
            }
        
        return Disposables.create()
    })
}
