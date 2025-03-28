import SwiftUI

struct TagsFilterView: View {
    @Binding var selectedTags: Set<Int> // Множество выбранных тегов
    let tags: [Tag]
    let onFilterChange: (Set<Int>) -> Void // Замыкание для передачи фильтров

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Кнопка "Все"
                Button(action: {
                    selectedTags.removeAll() // Убираем все выбранные теги
                    onFilterChange(selectedTags)
                }) {
                    Text("ВСЕ")
                        .padding()
                        .font(.system(size: 14))
                        .frame(height: 30)
                        .background(
                            selectedTags.isEmpty ? Color.Custom.gray : Color.white
                        )
                        .foregroundColor(selectedTags.isEmpty ? .white : Color.Custom.gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(selectedTags.isEmpty ? Color.clear : Color.Custom.gray, lineWidth: 2)
                        )
                        .cornerRadius(0)
                }

                // Кнопки для всех тегов
                ForEach(tags, id: \.id) { tag in
                    Button(action: {
                        toggleTagSelection(tag.id)
                    }) {
                        Text(tag.name.uppercased())
                            .padding()
                            .font(.system(size: 14))
                            .frame(height: 30)
                            .background(
                                selectedTags.contains(tag.id) ? Color.Custom.gray : Color.white
                            )
                            .foregroundColor(selectedTags.contains(tag.id) ? .white : Color.Custom.gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(selectedTags.contains(tag.id) ? Color.clear : Color.Custom.gray, lineWidth: 2)
                            )
                            .cornerRadius(0)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - func()

    // Метод для обработки выбора и снятия выбора тега
    private func toggleTagSelection(_ tagId: Int) {
        if selectedTags.contains(tagId) {
            selectedTags.remove(tagId) // Убираем тег, если он уже выбран
        } else {
            selectedTags.insert(tagId) // Добавляем тег
        }
        onFilterChange(selectedTags)
    }
}
