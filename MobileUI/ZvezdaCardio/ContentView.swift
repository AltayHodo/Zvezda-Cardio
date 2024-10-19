//
//  ContentView.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 19/10/24.
//

import Combine
import SwiftUI

struct ContentView: View {
    
    @StateObject var deviceLocation = LocationViewController.shared
    @State var tokens: Set<AnyCancellable> = []
    @State var coordinates: (lat: Double, lon: Double) = (0,0)
    
    var body: some View {
        VStack {
            Text("Latitude: \(coordinates.lat)").font(.largeTitle)
            Text("Longitude: \(coordinates.lon)").font(.largeTitle)
        }
        .onAppear {
            observeCoordinateUpdates()
            observeLocationDenied()
        }
    }
    
    func observeCoordinateUpdates() {
        deviceLocation.coordinatesPublisher.receive(on: DispatchQueue.main).sink { completion in
            if case .failure(let error) = completion {
                print(error)
            }
        } receiveValue: {coordinates in self.coordinates = (coordinates.latitude, coordinates.longitude)
        }
        .store(in: &tokens)
    }
    
    func observeLocationDenied() {
        deviceLocation.deniedLocationAccessPublisher.receive(on: DispatchQueue.main).sink {
            print("Show some kind of error alert")
        }
        .store(in: &tokens)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
