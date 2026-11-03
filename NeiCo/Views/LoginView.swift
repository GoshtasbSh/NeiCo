import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var basketVM: GroceryListViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            Button(action: login) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                }
            }
            .disabled(isLoading)
            Button("Login as Demo User") {
                // local demo account — create it with `python manage.py createsuperuser`
                username = "demo"
                password = "neico-demo-2025"
                login()
            }
        }
        .padding()
    }

    func login() {
        isLoading = true
        errorMessage = ""
        APIClient.shared.login(username: username, password: password) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    isLoggedIn = true
                    basketVM.loadBasket()
                } else {
                    errorMessage = error ?? "Login failed"
                }
            }
        }
    }
}
