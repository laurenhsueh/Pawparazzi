import SwiftUI

struct NewCollectionSheet: View {
    @Binding var name: String
    @Binding var error: String?
    let isCreating: Bool
    let onCreate: () -> Void
    
    @FocusState private var isFieldFocused: Bool
    
    private var isCreateDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("New Collection")
                .font(.custom("Inter-Regular", size: 18))
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.custom("Inter-Regular", size: 13))
                    .foregroundStyle(AppColors.mutedText)
                
                TextField("Downtown Regulars", text: $name)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColors.fieldBorder)
                    )
                    .focused($isFieldFocused)
                    .onChange(of: name) { _ in
                        error = nil
                    }
            }
            
            if let error {
                Text(error)
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(.red)
            }
            
            Button(action: onCreate) {
                HStack {
                    Spacer()
                    if isCreating {
                        ProgressView()
                    } else {
                        Text("Create")
                            .font(.custom("Inter-Regular", size: 16))
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(AppColors.primaryAction)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isCreateDisabled)
            .opacity(isCreateDisabled ? 0.6 : 1.0)
        }
        .padding(20)
        .presentationDetents([.fraction(0.32), .medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            isFieldFocused = true
        }
    }
}
