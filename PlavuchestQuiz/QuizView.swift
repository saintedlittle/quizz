import SwiftUI

struct QuizView: View {
    @State private var questions = quizQuestions.shuffled()
    @State private var index = 0
    @State private var selected: String? = nil
    @State private var score = 0
    @State private var finished = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue.opacity(0.18), .cyan.opacity(0.08), .clear],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                if finished {
                    VStack(spacing: 22) {
                        Image(systemName: score >= 7 ? "checkmark.seal.fill" : "book.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(score >= 7 ? .green : .blue)
                        Text("Тест завершён").font(.largeTitle.bold())
                        Text("\(score) из \(questions.count)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                        Text(resultText).foregroundStyle(.secondary)
                        Button("Пройти ещё раз") { restart() }
                            .buttonStyle(.borderedProminent).controlSize(.large)
                    }.padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Text("Вопрос \(index + 1) из \(questions.count)").font(.headline)
                                Spacer()
                                Text("Счёт: \(score)").foregroundStyle(.secondary)
                            }
                            ProgressView(value: Double(index + 1), total: Double(questions.count))

                            Text(questions[index].question)
                                .font(.title2.bold()).padding(.vertical, 8)

                            ForEach(questions[index].answers.shuffledStable(seed: questions[index].id.hashValue), id: \.self) { answer in
                                Button {
                                    choose(answer)
                                } label: {
                                    HStack {
                                        Text(answer).multilineTextAlignment(.leading)
                                        Spacer()
                                        if let selected {
                                            if answer == questions[index].correct {
                                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                            } else if answer == selected {
                                                Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                                            }
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
.background {
    background(for: answer)
        .clipShape(RoundedRectangle(cornerRadius: 14))
}
                                }
                                .buttonStyle(.plain)
                                .disabled(selected != nil)
                            }

                            if selected != nil {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(selected == questions[index].correct ? "Правильно!" : "Неправильно")
                                        .font(.headline)
                                        .foregroundStyle(selected == questions[index].correct ? .green : .red)
                                    Text(questions[index].explanation).foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))

                                Button(index == questions.count - 1 ? "Показать результат" : "Следующий вопрос") {
                                    next()
                                }
                                .buttonStyle(.borderedProminent).controlSize(.large)
                                .frame(maxWidth: .infinity)
                            }
                        }.padding()
                    }
                }
            }
            .navigationTitle("Плавучесть судна")
        }
    }

    private var resultText: String {
        switch score {
        case 9: return "Отлично — все ответы правильные."
        case 7...8: return "Очень хороший результат."
        case 5...6: return "Неплохо, но стоит повторить материал."
        default: return "Повтори материал и попробуй ещё раз."
        }
    }

    private func choose(_ answer: String) {
        guard selected == nil else { return }
        selected = answer
        if answer == questions[index].correct { score += 1 }
    }

    @ViewBuilder private func background(for answer: String) -> some View {
        if selected == nil { Color(.secondarySystemBackground) }
        else if answer == questions[index].correct { Color.green.opacity(0.16) }
        else if answer == selected { Color.red.opacity(0.16) }
        else { Color(.secondarySystemBackground) }
    }

    private func next() {
        if index + 1 < questions.count {
            index += 1
            selected = nil
        } else { finished = true }
    }

    private func restart() {
        questions = quizQuestions.shuffled()
        index = 0; selected = nil; score = 0; finished = false
    }
}

extension Array {
    func shuffledStable(seed: Int) -> [Element] {
        var result = self
        var state = UInt64(bitPattern: Int64(seed))
        guard result.count > 1 else { return result }
        for i in stride(from: result.count - 1, through: 1, by: -1) {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            let j = Int(state % UInt64(i + 1))
            result.swapAt(i, j)
        }
        return result
    }
}
