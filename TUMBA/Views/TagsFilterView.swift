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
                    Text("Все")
                        .padding()
                        .frame(height: 40)
                        .background(
                            selectedTags.isEmpty ? Color.ocean : Color.white
                        )
                        .foregroundColor(selectedTags.isEmpty ? .white : .ocean)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(selectedTags.isEmpty ? Color.clear : Color.ocean, lineWidth: 2)
                        )
                        .cornerRadius(0)
                }

                // Кнопки для всех тегов
                ForEach(tags, id: \.id) { tag in
                    Button(action: {
                        toggleTagSelection(tag.id)
                    }) {
                        Text(tag.name)
                            .padding()
                            .frame(height: 40)
                            .background(
                                selectedTags.contains(tag.id) ? Color.ocean : Color.white
                            )
                            .foregroundColor(selectedTags.contains(tag.id) ? .white : .ocean)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(selectedTags.contains(tag.id) ? Color.clear : Color.ocean, lineWidth: 2)
                            )
                            .cornerRadius(0)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

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
