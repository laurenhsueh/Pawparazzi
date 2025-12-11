import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @StateObject private var model = OnboardingModel()
    @StateObject private var signupViewModel = SignupViewModel()
    @StateObject private var loginViewModel = LoginViewModel()

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            VStack(spacing: 24) {
            switch model.currentStep {
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
                    goToLogin: { model.currentStep = 4 }
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
                    back: { model.currentStep = 1 },
                    goToSignUp: { model.currentStep = 2 }
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
        .animation(.easeInOut, value: model.currentStep)
    }


    private func nextStep() {
        if model.currentStep >= 3 {
            finishOnboarding()
        } else {
            model.currentStep += 1
        }
    }
    private func previousStep() { model.currentStep = max(model.currentStep - 1, 0) }
    private func finishOnboarding() {
        Task {
            await signupViewModel.completeOnboarding(using: model)
            if signupViewModel.errorMessage == nil {
                sessionManager.refreshSession() // ensure auth state updates immediately
                model.reset()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
