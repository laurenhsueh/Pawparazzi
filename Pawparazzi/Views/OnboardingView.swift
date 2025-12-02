//
//  OnboardingView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//

import SwiftUI

// MARK: - Onboarding Data Model
class OnboardingModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var fullName: String = ""
    @Published var profileImage: UIImage? = nil
    @Published var collections: [String] = []
}

// MARK: - Main Onboarding Flow
struct OnboardingView: View {
    @StateObject private var model = OnboardingModel()
    @State private var currentStep: Int = 0
    @State private var showingImagePicker: Bool = false
    @State private var newCollection: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            switch currentStep {
            case 0: WelcomeStep(next: { nextStep() })
            case 1: EmailPasswordStep(model: model, next: { nextStep() })
            case 2: UsernameStep(model: model, next: { nextStep() }, back: { previousStep() })
            case 3: NameStep(model: model, next: { nextStep() }, back: { previousStep() })
            case 4: ProfilePhotoStep(model: model, next: { nextStep() }, back: { previousStep() })
            case 5: OptionalCollectionsStep(model: model, next: { finishOnboarding() }, back: { previousStep() })
            default: Text("Unknown Step")
            }
        }
        .padding(16)
        .animation(.easeInOut, value: currentStep)
    }
    
    private func nextStep() { if currentStep < 6 { currentStep += 1 } }
    private func previousStep() { if currentStep > 0 { currentStep -= 1 } }
    
    private func finishOnboarding() {
        // Save onboarding data to your backend
        print("Finished onboarding:")
        print("Email: \(model.email), Username: \(model.username)")
    }
}

// MARK: - Step 0: Welcome
struct WelcomeStep: View {
    var next: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to Pawparazzi!")
                .font(.custom("AnticDidone-Regular", size: 28))
            
            Text("Get ready to take pics of cats 🐱")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.gray)
            
            Button(action: next) {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Secondary"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Step 1: Email / Password
struct EmailPasswordStep: View {
    @ObservedObject var model: OnboardingModel
    var next: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up or Login")
                .font(.custom("AnticDidone-Regular", size: 24))
            
            TextField("Email", text: $model.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemFill))
                .cornerRadius(8)
            
            SecureField("Password", text: $model.password)
                .padding()
                .background(Color(.secondarySystemFill))
                .cornerRadius(8)
            
            Button(action: next) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Secondary"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(model.email.isEmpty || model.password.isEmpty)
        }
    }
}

// MARK: - Step 2: Username
struct UsernameStep: View {
    @ObservedObject var model: OnboardingModel
    var next: () -> Void
    var back: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Choose a username")
                .font(.custom("AnticDidone-Regular", size: 24))
            
            TextField("Username", text: $model.username)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemFill))
                .cornerRadius(8)
            
            HStack {
                Button("Back", action: back)
                    .foregroundColor(.gray)
                Spacer()
                Button("Next", action: next)
                    .disabled(model.username.isEmpty)
            }
        }
    }
}

// MARK: - Step 3: Name
struct NameStep: View {
    @ObservedObject var model: OnboardingModel
    var next: () -> Void
    var back: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("What's your name?")
                .font(.custom("AnticDidone-Regular", size: 24))
            
            TextField("Full Name", text: $model.fullName)
                .padding()
                .background(Color(.secondarySystemFill))
                .cornerRadius(8)
            
            HStack {
                Button("Back", action: back)
                    .foregroundColor(.gray)
                Spacer()
                Button("Next", action: next)
                    .disabled(model.fullName.isEmpty)
            }
        }
    }
}

// MARK: - Step 4: Profile Photo
struct ProfilePhotoStep: View {
    @ObservedObject var model: OnboardingModel
    var next: () -> Void
    var back: () -> Void
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add a profile photo")
                .font(.custom("AnticDidone-Regular", size: 24))
            
            if let image = model.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
            }
            
            Button("Select Photo") { showingImagePicker = true }
            
            HStack {
                Button("Back", action: back).foregroundColor(.gray)
                Spacer()
                Button("Next", action: next).disabled(model.profileImage == nil)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $model.profileImage)
        }
    }
}

// MARK: - Step 6: Optional Collections
struct OptionalCollectionsStep: View {
    @ObservedObject var model: OnboardingModel
    var next: () -> Void
    var back: () -> Void
    @State private var newCollection: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Create Cat Collections (Optional)")
                .font(.custom("AnticDidone-Regular", size: 24))
            
            HStack {
                TextField("New collection name", text: $newCollection)
                    .padding()
                    .background(Color(.secondarySystemFill))
                    .cornerRadius(8)
                
                Button("Add") {
                    guard !newCollection.isEmpty else { return }
                    model.collections.append(newCollection)
                    newCollection = ""
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(model.collections, id: \.self) { col in
                        Text(col)
                            .padding(8)
                            .background(Color.purple.opacity(0.3))
                            .cornerRadius(8)
                    }
                }
            }
            
            HStack {
                Button("Back", action: back).foregroundColor(.gray)
                Spacer()
                Button(action: next) { Text("Skip / Finish") }
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
}
