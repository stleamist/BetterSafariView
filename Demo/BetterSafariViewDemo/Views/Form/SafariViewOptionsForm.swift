import SwiftUI
import BetterSafariView

struct SafariViewOptionsForm: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var options: SafariViewOptions
    @State private var temporaryOptions: SafariViewOptions
    
    private var urlIsInvalid: Bool {
        (temporaryOptions.url == nil) || !["http", "https"].contains(temporaryOptions.url?.scheme)
    }
    
    init(options: Binding<SafariViewOptions>) {
        self._options = options
        self._temporaryOptions = State(wrappedValue: options.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("URL")) {
                    TextField(gitHubRepositoryURLString, text: $temporaryOptions.urlString)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Configurations")) {
                    Toggle("Enter Reader If Available", isOn: $temporaryOptions.entersReaderIfAvailable)
                    Toggle("Enable Bar Collapsing", isOn: $temporaryOptions.barCollapsingEnabled)
                }
                
                Section(header: Text("Modifiers")) {
                    HStack {
                        let labelText = "Control Accent Color"
                        Text(labelText)
                        Spacer()
                        if temporaryOptions.usePreferredControlAccentColor {
                            ColorPicker(labelText, selection: $temporaryOptions.preferredControlAccentColorInUse)
                                .labelsHidden()
                        }
                        Toggle(labelText, isOn: $temporaryOptions.usePreferredControlAccentColor)
                            .labelsHidden()
                    }
                    
                    HStack {
                        let labelText = "Bar Accent Color"
                        Text(labelText)
                        Spacer()
                        if temporaryOptions.usePreferredBarAccentColor {
                            ColorPicker(labelText, selection: $temporaryOptions.preferredBarAccentColorInUse)
                                .labelsHidden()
                        }
                        Toggle(labelText, isOn: $temporaryOptions.usePreferredBarAccentColor)
                            .labelsHidden()
                    }
                    
                    Picker("Dismiss Button Style", selection: $temporaryOptions.dismissButtonStyle) {
                        Text("Done")
                            .tag(SafariView.DismissButtonStyle.done)
                        Text("Close")
                            .tag(SafariView.DismissButtonStyle.close)
                        Text("Cancel")
                            .tag(SafariView.DismissButtonStyle.cancel)
                    }
                }
            }
            .navigationTitle(Text("Safari Options"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        options = temporaryOptions
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SafariViewOptionsForm_Previews: PreviewProvider {
    static var previews: some View {
        SafariViewOptionsForm(options: .constant(.init()))
    }
}
