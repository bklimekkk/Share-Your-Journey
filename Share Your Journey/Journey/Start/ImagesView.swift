//
//  ImagesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 04/07/2022.
//

import SwiftUI
import MapKit

struct ImagesView: View {
    @Binding var images: [SinglePhoto]
    @Binding var imagesLocations: [CLLocationCoordinate2D]
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: []) var currentImages: FetchedResults<CurrentImage>
    @FetchRequest(sortDescriptors: []) var currentLocations: FetchedResults<CurrentLocation>
    var body: some View {
        NavigationView {
            VStack {
                if images.isEmpty {
                    Spacer()
                    Text("No images to show")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(images, id: \.number) { image in
                                
                                ZStack {
                                    Image(uiImage: image.photo)
                                        .resizable()
                                        .shadow(color: .gray, radius: 2)
                                        .scaledToFill()
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 1)
                                    VStack {
                                        HStack{
                                            Spacer()
                                            Button{
                                                deleteImage(number: image.number)
                                                
                                            }label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 30))
                                                    .padding()
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Journey Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Back to the journey") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func deleteImage(number: Int) {
        let shiftIndex = number
        
        withAnimation {
            imagesLocations.remove(at: shiftIndex)
            images.remove(at: shiftIndex)
            
            var imagesCounter = 0
            
            for i in currentImages {
                if shiftIndex == imagesCounter {
                    moc.delete(i)
                    break
                }
                imagesCounter += 1
            }
            
            
            var locationsCounter = 0
            for i in currentLocations {
                if shiftIndex == locationsCounter {
                    moc.delete(i)
                    break
                }
                locationsCounter += 1
            }
            
            if !images.isEmpty && shiftIndex != images.count {
                for i in shiftIndex...images.count - 1 {
                    images[i].number = images[i].number - 1
                }
                
                for i in currentImages {
                    if i.id > shiftIndex {
                        i.id = i.id - 1
                    }
                }
            }
            
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }
}
