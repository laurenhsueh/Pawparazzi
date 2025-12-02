import SwiftUI

struct OnboardingView: View {
    @StateObject private var model = OnboardingModel()
    @State private var currentStep = 0

    var body: some View {
        VStack(spacing: 24) {
            switch currentStep {
            case 0:
                WelcomeStep(
                    next: { nextStep() },
                    goToLogin: { currentStep = 3 }
                )
                
            case 1:
                SignupView(
                    model: model,
                    next: { nextStep() },
                    back: { previousStep() },
                    goToLogin: { currentStep = 3 }
                )

            case 2:
                SetupProfileView(
                    model: model,
                    next: { nextStep() },
                    back: { previousStep() }
                )

            case 3:
                LoginView(
                    back: { currentStep = 0 },
                    goToSignUp: { currentStep = 1 }
                )
                
            case 4:
                FeedView()

            default:
                WelcomeStep(
                    next: { nextStep() },
                    goToLogin: { currentStep = 3 }
                )
            }
        }
        .padding(16)
        .animation(.easeInOut, value: currentStep)
    }


    private func nextStep() {
        if currentStep == 2 {
            finishOnboarding()
        } else {
            currentStep += 1
        }
    }
    private func previousStep() { currentStep = max(currentStep - 1, 0) }
    private func finishOnboarding() {
        Task {
            do {
                //try await model.saveToSupabase()
                currentStep = 4                    // ⬅️ Switch to main app root
            } catch {
                print("Error saving onboarding data: \(error)")
            }
        }
    }
}

#Preview {
    OnboardingView()
}
