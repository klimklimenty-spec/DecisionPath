//
//  GeminiService.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import SwiftUI

class GeminiService {
    // API Key должен быть защищен и не храниться в коде в открытом виде для продакшена.
    // Рассмотрите использование xcconfig файлов или других методов для его безопасного хранения.
    private let apiKey = "AIzaSyDeKZRT21892LO6NjoSWdWgq3OfXeiOG1c" // ЗАМЕНИТЕ НА ВАШ КЛЮЧ!
    private let modelName = "gemini-1.5-flash" // Или другая подходящая модель
    private lazy var baseURL = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent"

    enum GeminiError: Error, LocalizedError {
        case invalidUrl
        // case invalidImageData // Не используется в этой функции
        case networkError(Error)
        case apiError(String) // Сообщение об ошибке от API, включая статус код
        case decodingError(Error) // Ошибка декодирования основного ответа Gemini
        case noContentGenerated
        case resultJsonDecodingError(Error) // Ошибка декодирования JSON *внутри* текстового ответа

        var errorDescription: String? {
            switch self {
            case .invalidUrl: return "Invalid API URL."
            // case .invalidImageData: return "Failed to convert image to data."
            case .networkError(let underlyingError): return "Network error: \(underlyingError.localizedDescription)"
            case .apiError(let message): return "Gemini API Error: \(message)"
            case .decodingError(let underlyingError): return "API response decoding error: \(underlyingError.localizedDescription)"
            case .noContentGenerated: return "The model did not generate any content."
            case .resultJsonDecodingError(let underlyingError): return "Error decoding the JSON result from text: \(underlyingError.localizedDescription)"
            }
        }
    }

    // --- Структуры для запроса и ответа (оставляем как есть, они достаточно гибкие) ---
    struct GeminiRequest: Encodable {
        let contents: [Content]
        let generationConfig: GenerationConfig? // Добавим для контроля вывода

        init(contents: [Content], generationConfig: GenerationConfig? = nil) {
            self.contents = contents
            self.generationConfig = generationConfig
        }
    }

    struct Content: Encodable {
        let parts: [Part]
    }

    struct Part: Encodable {
        let text: String
        // inlineData убрано, так как изображения не отправляем для этой функции
    }
    
    // Конфигурация генерации для запроса JSON
    struct GenerationConfig: Encodable {
        let responseMimeType: String // "application/json"
    }


    struct GeminiResponse: Decodable {
        let candidates: [Candidate]?
        let promptFeedback: PromptFeedback?
    }

    struct Candidate: Decodable {
        let content: ResponseContent?
        let finishReason: String?
        // let safetyRatings: [SafetyRating]? // Можно раскомментировать, если нужны
    }

    struct ResponseContent: Decodable {
        let parts: [ResponsePart]?
        // let role: String? // Можно раскомментировать
    }

    struct ResponsePart: Decodable {
        let text: String? // Ожидаем, что здесь будет JSON-строка
    }
    
    struct PromptFeedback: Decodable {
        let blockReason: String?
        // let safetyRatings: [SafetyRating]?
    }

    // --- Структура для ожидаемого JSON-ответа от модели (список названий) ---
    struct GeneratedTitlesResponse: Decodable {
        let titles: [String]
    }


    func generateCardTitles(prompt: String, count: Int) async -> Result<[String], GeminiError> {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            return .failure(.invalidUrl)
        }

        // 1. Сформулировать промпт для Gemini
        let systemPrompt = """
        You are a creative assistant for a "Pick the Card" game.
        The user will provide a theme or a topic.
        Your task is to generate exactly \(count) unique and concise item names or titles related to that theme. These items will be displayed on cards for the user to choose between.
        The items should be suitable for a general audience. Avoid overly complex, niche, or controversial topics unless specifically requested.
        
        Return the result ONLY as a valid JSON object with a single key "titles", where the value is an array of \(count) strings.
        Each string in the array should be one generated item name.
        
        Example for theme "Types of Fruits" and count 4:
        {
          "titles": ["Apple", "Banana", "Orange", "Strawberry"]
        }

        Example for theme "Legendary Creatures" and count 8:
        {
          "titles": ["Dragon", "Unicorn", "Griffin", "Phoenix", "Minotaur", "Hydra", "Sphinx", "Cyclops"]
        }
        
        Strictly adhere to this JSON format. Do not add any introductory text, explanations, or markdown formatting like ```json ... ``` around the JSON object.
        The user's theme is: "\(prompt)"
        """

        // 2. Сформировать тело запроса
        let requestPayload = GeminiRequest(
            contents: [Content(parts: [Part(text: systemPrompt)])],
            generationConfig: GenerationConfig(responseMimeType: "application/json") // Запрашиваем JSON
        )

        // 3. Создать URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(requestPayload)
        } catch {
            return .failure(.decodingError(error))
        }

        // 4. Выполнить запрос
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
                print("Gemini API Error (HTTP \(statusCode)): \(errorBody)")
                return .failure(.apiError("HTTP Status \(statusCode). Details: \(errorBody)"))
            }

            // 5. Декодировать основной ответ Gemini
            let geminiResponse: GeminiResponse
            do {
                 geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            } catch {
                 print("Gemini API Error (Decoding Response): \(error)")
                 print("Raw data: \(String(data: data, encoding: .utf8) ?? "nil")")
                 return .failure(.decodingError(error))
            }
            
            if let feedback = geminiResponse.promptFeedback, let reason = feedback.blockReason {
                return .failure(.apiError("Request blocked by API. Reason: \(reason)"))
            }

            // 6. Извлечь текстовую часть ответа (ожидаем там наш JSON-строку)
            guard let candidate = geminiResponse.candidates?.first,
                  let responsePart = candidate.content?.parts?.first,
                  let resultText = responsePart.text else { // resultText должен быть JSON-строкой
                print("Gemini API Error: No content generated or missing text part.")
                return .failure(.noContentGenerated)
            }
            
            print("--- Gemini Raw JSON Text Response ---")
            print(resultText)
            print("----------------------------------")

            // 7. Декодировать JSON *внутри* текстового ответа
            guard let resultData = resultText.data(using: .utf8) else {
                 return .failure(.resultJsonDecodingError(NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert result text to UTF-8 data."])))
            }

            let generatedTitlesResponse: GeneratedTitlesResponse
            do {
                generatedTitlesResponse = try JSONDecoder().decode(GeneratedTitlesResponse.self, from: resultData)
            } catch {
                print("Error decoding GeneratedTitlesResponse JSON: \(error)")
                print("Text that failed decoding: \(resultText)")
                return .failure(.resultJsonDecodingError(error))
            }

            if generatedTitlesResponse.titles.count != count {
                print("Warning: Gemini returned \(generatedTitlesResponse.titles.count) titles, but \(count) were requested.")
                // Можно вернуть ошибку или усечь/дополнить список, но лучше если модель следует инструкциям.
            }

            return .success(generatedTitlesResponse.titles)

        } catch {
            if let urlError = error as? URLError {
                return .failure(.networkError(urlError))
            }
            return .failure(.networkError(error)) // Общая ошибка сети
        }
    }
}
