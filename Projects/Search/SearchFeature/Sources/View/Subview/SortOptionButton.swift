struct SortOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .notosans(.body4Semibold)
                .foregroundStyle(isSelected ?
                    Color.livithColor(.black100) :
                    Color.livithColor(.white100))
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(isSelected ?
                            Color.livithColor(.yellow30) :
                            .clear)
                }
        }
    }
}