//
//  ConfigurableModelService.swift
//  Chat
//
//  Created by Fernando Barbat on 9/8/24.
//

import Settings
import SwiftExtensions

/// Dynamic implementation of ModelService which enforces the active model.
final actor ConfigurableModelService: ModelService {
    private let modelServiceFactory: (GeneralSettings.ActiveModel) async  -> ModelService
    
    enum State {
        /// Contains continuations of calls waiting for a model service
        case loading([CheckedContinuation<ModelService, Never>])
        
        case loaded(any ModelService)
    }
    
    private var state: State = .loading([])
    
    private let task = AttachedTask<Void, Never>()
    
    init(
        settingsApplicationModel: SettingsApplicationModel,
        modelServiceFactory: @escaping (GeneralSettings.ActiveModel) async -> ModelService
    ) {
        self.modelServiceFactory = modelServiceFactory
        
        task.run { [weak self] in
            let activeModel = await settingsApplicationModel.get(\.general.activeModel)
            await self?.setActiveModel(activeModel)
            for await activeModel in await settingsApplicationModel.onChange(of: \.general.activeModel) {
                await self?.setActiveModel(activeModel)
            }
        }
    }
    
    private func setActiveModel(_ activeModel: GeneralSettings.ActiveModel) async {
        let modelService = await modelServiceFactory(activeModel)
        
        if case let State.loading(continuations) = state {
            continuations.forEach { continuation in
                continuation.resume(returning: modelService)
            }
        }
        
        state = .loaded(modelService)
    }
    
    func chat(messages: [ChatMessage]) async -> AsyncThrowingStream<ModelAction, any Error>  {
        let modelService = await eventualModelService()
        return await modelService.chat(messages: messages)
    }
    
    private func eventualModelService() async -> ModelService {
        switch state {
        case .loading(var continuations):
            return await withCheckedContinuation { continuation in
                continuations.append(continuation)
                state = .loading(continuations)
            }
        case .loaded(let modelService):
            return modelService
        }
    }
}
