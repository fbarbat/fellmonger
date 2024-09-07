import SwiftUI

import MacOSSwiftExtensions
import Settings

public struct SettingsView: View {
    let model: any SettingsViewModel
    
    public init(model: any SettingsViewModel) {
        self.model = model
    }
    
    private enum Tabs: Hashable {
        case general
        case ollama
        case openai
        case anthropic
    }
    
    public var body: some View {
        TabView {
            GeneralSettingsView(model: model.general)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            
            OllamaSettingsView(model: model.ollama)
                .tabItem {
                    Label {
                        Text("Ollama")
                    } icon: {
                        Image("ollama", bundle: .module)
                    }
                }
                .tag(Tabs.ollama)
            
            OpenAISettingsView(model: model.openAI)
                .tabItem {
                    Label {
                        Text("OpenAI")
                    } icon: {
                        Image("openai", bundle: .module)
                    }
                }
                .tag(Tabs.openai)
            
            AnthropicSettingsView(model: model.anthropic)
                .tabItem {
                    Label {
                        Text("Anthropic")
                    } icon: {
                        Image("anthropic", bundle: .module)
                    }
                }
                .tag(Tabs.anthropic)
        }
        .padding()
    }
}

private struct GeneralSettingsView: View {
    @BindableProtocol var model: any GeneralSettingsViewModel
    
    var body: some View {
        Form(content: {
            Picker("Active Model", selection: $model.activeModel) {
                ForEach(GeneralSettingsViewModelActiveModel.allCases) { activeModel in
                    Text(activeModel.label)
                        .tag(activeModel)
                }
            }
        })
    }
}

private struct OllamaSettingsView: View {
    @BindableProtocol var model: any OllamaSettingsViewModel
    
    var body: some View {
        Form {
            TextField("URL", text: $model.url)
            TextField("Model name", text: $model.model)
        }
    }
}

private struct OpenAISettingsView: View {
    @BindableProtocol var model: any OpenAISettingsViewModel
    
    var body: some View {
        Form {
            SecureField("Key", text: $model.key)
            TextField("Model name", text: $model.model)
        }
    }
}

private struct AnthropicSettingsView: View {
    @BindableProtocol var model: any AnthropicSettingsViewModel
    
    var body: some View {
        Form {
            SecureField("Key", text: $model.key)
            TextField("Model name", text: $model.model)
        }
    }
}

#Preview {
    /// Unfortunatelly, this preview fails. Seems like an Xcode bug dealing with packages.
    /// TODO: Report this
    SettingsView(model: FakeSettingsViewModel(
        general: FakeGeneralSettingsViewModel(
            activeModel: .ollama
        ),
        ollama: FakeOllamaSettingsViewModel(
            url: "http://localhost:12345",
            model: "llama3.1"
        ),
        openAI: FakeOpenAISettingsViewModel(
            key: "secret key, don't show this",
            model: "some chatGPT model"
        ),
        anthropic: FakeAnthropicSettingsViewModel(
            key: "secret key, don't show this",
            model: "some anthropic model"
        )
    ))
}
