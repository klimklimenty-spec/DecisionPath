//
//  DataManager.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import SwiftUI // Needed for GameTheme and CardItem if they are defined in a SwiftUI context elsewhere

class DataManager {
    static let shared = DataManager()
    
    private init(){
        
    }
    
    let predefinedThemes: [GameTheme] = [
        // Neutral Themes (8 cards each)
        GameTheme(title: "Peak Performance", iconName: "theme_icon_peak_performance"), // Подберите иконку для темы
        GameTheme(title: "Extreme Sports", iconName: "sports_up"),
        GameTheme(title: "Gear Up!", iconName: "theme_icon_gear_up"),
        GameTheme(title: "World Arenas", iconName: "theme_icon_world_arenas"),
        GameTheme(title: "Strategy & Sweat", iconName: "theme_icon_strategy_sweat"),

        // Neutral Themes (4 cards each)
        GameTheme(title: "Weather Warriors", iconName: "theme_icon_weather_warriors"),
        GameTheme(title: "Core Actions", iconName: "theme_icon_core_actions"),
        GameTheme(title: "Playing Grounds", iconName: "theme_icon_playing_grounds"),
        GameTheme(title: "Moments of Triumph", iconName: "theme_icon_moments_of_triumph"),
    ]
    
    let sportType: [CardItem] = [
        CardItem(name: "Skateboarding", imageName: "skateIcon"),
        CardItem(name: "Surfing", imageName: "surfIcon"),
        CardItem(name: "Snowboarding", imageName: "snowbIcon"),
        CardItem(name: "Riding", imageName: "rideIcon")
    ]
    
    let peakPerformanceCards: [CardItem] = [
        CardItem(name: "The Finish", imageName: "peak_finish_line"),
        CardItem(name: "Perfect Aim", imageName: "peak_target_hit"),
        CardItem(name: "Graceful Leap", imageName: "peak_graceful_leap"),
        CardItem(name: "Powerful Stride", imageName: "peak_powerful_stride"),
        CardItem(name: "Clean Dive", imageName: "peak_clean_dive"),
        CardItem(name: "Summit Reached", imageName: "peak_summit_reached"),
        CardItem(name: "Max Effort", imageName: "peak_max_effort"),
        CardItem(name: "Victory Shared", imageName: "peak_victory_shared")
    ]

    let gearUpCards: [CardItem] = [
        CardItem(name: "Running Shoe", imageName: "gear_running_shoe"),
        CardItem(name: "All-Purpose Ball", imageName: "gear_sports_ball"),
        CardItem(name: "Hydration Bottle", imageName: "gear_water_bottle"),
        CardItem(name: "Versatile Racket", imageName: "gear_sports_racket"),
        CardItem(name: "Timing Device", imageName: "gear_stopwatch"),
        CardItem(name: "Performance Gloves", imageName: "gear_athletic_gloves"),
        CardItem(name: "Fitness Mat", imageName: "gear_exercise_mat"),
        CardItem(name: "Coach's Whistle", imageName: "gear_whistle")
    ]

    let worldArenasCards: [CardItem] = [
        CardItem(name: "Grand Stadium", imageName: "arena_outdoor_stadium"),
        CardItem(name: "Indoor Court", imageName: "arena_indoor_court"),
        CardItem(name: "Aquatic Center", imageName: "arena_aquatic_center"),
        CardItem(name: "Ice Arena", imageName: "arena_ice_rink"),
        CardItem(name: "Cycling Track", imageName: "arena_velodrome"),
        CardItem(name: "Beach Court", imageName: "arena_beach_court"),
        CardItem(name: "Training Hall", imageName: "arena_dojo_hall"),
        CardItem(name: "Nature's Trail", imageName: "arena_mountain_trail")
    ]

    let strategyAndSweatCards: [CardItem] = [
        CardItem(name: "Game Plan", imageName: "tactic_playbook"),
        CardItem(name: "Mental Focus", imageName: "tactic_focus_mind"),
        CardItem(name: "Team Synergy", imageName: "tactic_team_synergy"),
        CardItem(name: "Endurance", imageName: "tactic_endurance_run"),
        CardItem(name: "Precision", imageName: "tactic_precision_aim"),
        CardItem(name: "Skill Growth", imageName: "tactic_skill_growth"),
        CardItem(name: "Offense/Defense", imageName: "tactic_offense_defense"),
        CardItem(name: "The Journey", imageName: "tactic_long_journey")
    ]

    // --- Themes with 4 Cards ---

    let weatherWarriorsCards: [CardItem] = [
        CardItem(name: "Sunny Skies", imageName: "weather_sunny_day"),
        CardItem(name: "Rainy Challenge", imageName: "weather_rainy_challenge"),
        CardItem(name: "Snowy Field", imageName: "weather_snowy_field"),
        CardItem(name: "Windy Conditions", imageName: "weather_windy_conditions")
    ]

    let coreActionsCards: [CardItem] = [
        CardItem(name: "Running Fast", imageName: "action_running_icon"),
        CardItem(name: "Jumping High", imageName: "action_jumping_icon"),
        CardItem(name: "Throwing Far", imageName: "action_throwing_icon"),
        CardItem(name: "Lifting Strong", imageName: "action_lifting_icon")
    ]

    let playingGroundsCards: [CardItem] = [
        CardItem(name: "Natural Grass", imageName: "surface_green_grass"),
        CardItem(name: "Hardwood Court", imageName: "surface_hardwood_court"),
        CardItem(name: "Artificial Turf", imageName: "surface_artificial_turf"),
        CardItem(name: "Clay Surface", imageName: "surface_clay_track")
    ]

    let momentsOfTriumphCards: [CardItem] = [
        CardItem(name: "Gold Medal", imageName: "triumph_gold_medal"),
        CardItem(name: "Winner's Trophy", imageName: "triumph_trophy_cup"),
        CardItem(name: "Celebration Burst", imageName: "triumph_confetti_burst"),
        CardItem(name: "Victorious Pose", imageName: "triumph_raised_hands")
    ]


    // MARK: - Function to Get Cards for a Theme
    // (This function would typically live in GameThemesView or a dedicated data manager class/struct)

    func getCards(for themeTitle: String) -> [CardItem] {
        switch themeTitle {
        // Neutral Themes
        case "Extreme Sports":
            return sportType
        case "Peak Performance":
            return peakPerformanceCards
        case "Gear Up!":
            return gearUpCards
        case "World Arenas":
            return worldArenasCards
        case "Strategy & Sweat":
            return strategyAndSweatCards
        case "Weather Warriors":
            return weatherWarriorsCards
        case "Core Actions":
            return coreActionsCards
        case "Playing Grounds":
            return playingGroundsCards
        case "Moments of Triumph":
            return momentsOfTriumphCards

        default:
            print("Warning: Card data not found for theme title: \(themeTitle). Returning empty array.")
            return []
        }
    }
}


