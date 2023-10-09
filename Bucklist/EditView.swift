//
//  EditView.swift
//  Bucklist
//
//  Created by Aaron Brown on 10/11/23.
//

import MapKit
import SwiftUI

struct EditView: View {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Environment(\.dismiss) private var dismiss
    var location: Location
    var onSave: (Location) -> Void
    @State var cameraPosition: MapCameraPosition
    
    @State private var name: String
    @State private var description: String
    
    @State private var loadingState = LoadingState.loading
    @State private var pages: [Page] = []
    
    var body: some View {
        VStack {
            Map(position: $cameraPosition) {
                Annotation(location.name, coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "star.circle")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                        
                        Text("\(name == location.name ? location.name : name)")
                            .fixedSize()
                    }
                }
                .annotationTitles(.hidden)
            }
            .frame(height: 200)
            .padding(.bottom, -7)
            NavigationView {
                Form {
                    Section("Location Details") {
                        TextField("Placename", text: $name)
                    }
                    Section("Description"){
                        TextEditor(text: $description)
                            .frame(height: 50)
                    }
                    Section("Nearby....") {
                        switch loadingState {
                        case .loading:
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        case .loaded:
                            ForEach(pages, id: \.pageid) { page in
                                LazyVStack(alignment: .leading) {
                                    Text(page.title)
                                        .font(.headline)
                                    + Text(": ")
                                    + Text(page.description)
                                        .italic()
                                }
                            }
                        case .failed:
                            Text("Please try again later.")
                        }
                    }
                }
                .navigationTitle("Place Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        var newLocation = location
                        newLocation.name = name
                        newLocation.description = description
                        newLocation.id = UUID()
                        onSave(newLocation)
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                }
                .task { await fetchNearbyPlaces() }
            }
        }
    }
    // @escaping mean that the function "onSave" will not called immediately. It will be called in ContentView when the sheet is dismissed.
    init(location: Location, cameraPosition: MapCameraPosition, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        _cameraPosition = State(initialValue: MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
        )))
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    func fetchNearbyPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else { return print("Bad URL: \(urlString)") }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode(Result.self, from: data)
            pages = items.query.pages.values.sorted()
            loadingState = .loaded
        } catch {
            loadingState = .failed
        }
    }
}

#Preview {
    EditView(location: Location.example, cameraPosition: MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141),
        span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
    ))) { _ in } // Closure that will be ran elsewhere or "on escaping this view" - "PlaceHolder."
}
