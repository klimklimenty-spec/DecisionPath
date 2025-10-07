//
//  CreateEditThemeView.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import Foundation
import SwiftUI
import PhotosUI // Для PhotosPicker

@available(iOS 16.0, *)
struct CreateEditThemeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: CreateEditThemeViewModel

    var onDismiss: (() -> Void)?

    @available(iOS 16.0, *)
    init(realmService: RealmService, themeToEdit: CustomThemeObject? = nil, onDismiss: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: CreateEditThemeViewModel(realmService: realmService, themeToEdit: themeToEdit))
        self.onDismiss = onDismiss
    }
    
    let cardColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundStyle(.darkBlue)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Theme Title
                        Text("Theme Title")
                            .sectionTitleStyle()
                        
                        TextField("Enter theme title...", text: $viewModel.themeTitle)
                            .textFieldStyle(NeonTextFieldStyle())
                            .onChange(of: viewModel.themeTitle) { _ in viewModel.validateForm() }

                        // MARK: - Number of Cards
                        Text("Number of Cards")
                            .sectionTitleStyle()
                        
                        Picker("Number of Cards", selection: $viewModel.numberOfCards) {
                            Text("4 Cards").tag(4)
                            Text("8 Cards").tag(8)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .colorMultiply(.neonGreen)
                        .onChange(of: viewModel.numberOfCards) { _ in viewModel.validateForm() }
                        .preferredColorScheme(.dark)


                        // MARK: - Cards Input
                        Text("Cards (\(viewModel.cardData.filter({!$0.title.isEmpty || $0.uiImage != nil}).count)/\(viewModel.numberOfCards) filled)")
                            .sectionTitleStyle()
                            .padding(.top)

                        LazyVGrid(columns: cardColumns, spacing: 15) {
                            ForEach($viewModel.cardData, id: \.viewId) { $cardInput in
                                CardInputCell(
                                    cardInputData: $cardInput,
                                    onSelectImage: {
                                        viewModel.photoPickerTargetIndex = viewModel.cardData.firstIndex(where: { $0.viewId == cardInput.viewId })
                                    },
                                    onClearImage: {
                                        if let index = viewModel.cardData.firstIndex(where: { $0.viewId == cardInput.viewId }) {
                                            viewModel.clearImage(forCardIndex: index)
                                        }
                                    }
                                )
                                .onChange(of: cardInput.title) { _ in viewModel.validateForm() }
                            }
                        }
                        
                        Spacer(minLength: 30)

                    }
                    .padding()
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Picker" : "Create New Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.deepPurple, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissView()
                    }
                    .foregroundColor(.neonGreen)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveTheme()
                        dismissView()
                    }
                    .foregroundColor(viewModel.canSave ? .neonGreen : .gray)
                    .disabled(!viewModel.canSave)
                }
            }
            .photosPicker(
                isPresented: Binding<Bool>(
                    get: { viewModel.photoPickerTargetIndex != nil },
                    set: { if !$0 { viewModel.photoPickerTargetIndex = nil } }
                ),
                selection: $viewModel.selectedPhotoPickerItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: viewModel.selectedPhotoPickerItem) { newItem in
                 if newItem == nil {
                     viewModel.photoPickerTargetIndex = nil
                 }
            }
        }
        .tint(.white)
    }
    
    private func dismissView() {
        onDismiss?()
        dismiss()
    }
}

// MARK: - Card Input Cell View
struct CardInputCell: View {
    @Binding var cardInputData: CardInputData
    var onSelectImage: () -> Void
    var onClearImage: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Button(action: onSelectImage) {
                    Group {
                        if let uiImage = cardInputData.uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            VStack {
                                Spacer()
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 30, weight: .light))
                                    .foregroundColor(.neonGreen.opacity(0.7))
                                Text("Tap to add")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 100) // Фиксированная высота для области изображения
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
                    )
                }
                
                if cardInputData.uiImage != nil {
                    Button(action: onClearImage) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .background(Circle().fill(Color.black.opacity(0.5)))
                            .font(.callout)
                            .padding(5)
                    }
                }
            }

            TextField("Card title...", text: $cardInputData.title)
                .textFieldStyle(NeonTextFieldStyle(fontSize: 14, cornerRadius: 8))
        }
        .padding(8)
        .background(Color.deepPurple.opacity(0.6))
        .cornerRadius(12)
    }
}

// MARK: - Custom Styles (примеры, вынесите в отдельный файл)
struct SectionTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3.weight(.semibold))
            .foregroundColor(.neonGreen.opacity(0.8))
    }
}

extension View {
    func sectionTitleStyle() -> some View {
        self.modifier(SectionTitleStyle())
    }
}

struct NeonTextFieldStyle: TextFieldStyle {
    var fontSize: CGFloat = 16
    var cornerRadius: CGFloat = 10
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: fontSize))
            .padding(10)
            .background(Color.black.opacity(0.3))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.neonGreen.opacity(0.6), lineWidth: 1)
            )
            .foregroundColor(.white)
            .accentColor(.neonGreen) // Цвет курсора
    }
}


