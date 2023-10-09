//
//  ContentView.swift
//  Bucklist
//
//  Created by Aaron Brown on 10/9/23.
//
import MapKit
import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        if viewModel.isUnlocked {
            ZStack {
                Map(position: $viewModel.cameraPosition) {
                    ForEach(viewModel.locations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            VStack {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundColor(.red)
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                
                                Text("\(location.name)")
                            }
                            .onTapGesture {
                                viewModel.selectedPlace = location
                            }
                        }
                        .annotationTitles(.hidden)
                    }
                }
                .onMapCameraChange { mapCameraUpdateContext in
                    viewModel.currentPosition = mapCameraUpdateContext.camera.centerCoordinate
                }
                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            viewModel.addLocation()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                    }
                }
            }
            // Sheet(item: $selectedPlace) { place in } where item is a binding to an optional value where place is the unwrapped value in the sheet
            .sheet(item: $viewModel.selectedPlace) { place in
                EditView(location: place, cameraPosition: viewModel.cameraPosition) { newLocation in
                    viewModel.updateLocation(location: newLocation)
                }
            }
        } else {
            Button {
                viewModel.authenticate()
            } label: {
                Text("Bucketlist")
            }
            
        }
    }
}

#Preview {
    ContentView()
}

