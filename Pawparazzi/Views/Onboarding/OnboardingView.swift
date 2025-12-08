import SwiftUI

struct OnboardingView: View {
    @StateObject private var model = OnboardingModel()
    @StateObject private var signupViewModel = SignupViewModel()
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var currentStep = 0

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
            switch currentStep {
            case 0:
                WelcomeStep(
                    next: { nextStep() },
                )
            
            case 1:
                OnboardingInfoView(
                    next: { nextStep() },
                    back: { previousStep() },
                )
                
            case 2:
                SignupView(
                    model: model,
                    viewModel: signupViewModel,
                    next: { nextStep() },
                    back: { previousStep() },
                    goToLogin: { currentStep = 4 }
                )

            case 3:
                SetupProfileView(
                    model: model,
                    isSubmitting: signupViewModel.isLoading,
                    errorMessage: signupViewModel.errorMessage,
                    next: { nextStep() },
                    back: { previousStep() }
                )

            case 4:
                LoginView(
                    viewModel: loginViewModel,
                    back: { currentStep = 1 },
                    goToSignUp: { currentStep = 2 }
                )

            default:
                WelcomeStep(
                    next: { nextStep() },
                )
            }
        }
            .disabled(signupViewModel.isLoading)

            if signupViewModel.isLoading {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                ProgressView("Creating your account...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
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
            await signupViewModel.completeOnboarding(using: model)
        }
    }
}

#Preview {
    OnboardingView()
}
