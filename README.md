# Binary Spectrum

**Binary Spectrum** is an interactive iPad game designed to teach core computer science concepts to middle school students through storytelling, mini-games, and playful experimentation. The app uses a gender-sensitive, inclusive design to appeal to a broad range of learners and promote computational thinking beyond just coding.

## 🧠 Overview

Binary Spectrum introduces foundational computing ideas through three themed mini-games inspired by popular unplugged activities. The app blends artistic expression with logic-based challenges, making abstract CS concepts tangible and fun. It’s ideal for informal learning environments like coding clubs, workshops, or classrooms.

### 🎯 Educational Focus
- Computational Thinking  
- Binary Representation  
- Digital Image Encoding  
- RGB Color Systems & Transparency

## 🎮 Mini-Games# Binary Spectrum

**Binary Spectrum** is an interactive iPad game designed to teach core computer science concepts to middle school students through storytelling, mini-games, and playful experimentation. The app uses a gender-sensitive, inclusive design to appeal to a broad range of learners and promote computational thinking beyond just coding.

---

## 📚 Table of Contents

1. [Introduction](#introduction)
2. [User Guide](#user-guide)
   - [Getting Started](#getting-started)
   - [Mini-Games Overview](#mini-games-overview)
   - [Difficulty Modes](#difficulty-modes)
   - [Achievements and Progress](#achievements-and-progress)
   - [Language Settings](#language-settings)
3. [Installation](#installation)
4. [Development](#development)
   - [Architecture Overview](#architecture-overview)
   - [Code Structure](#code-structure)
   - [UML Models & Diagrams](#uml-models--diagrams)

---

## 🧠 Introduction

Binary Spectrum tackles two pressing challenges in computer science education:

- **Gender Inequality**: Through inclusive visuals, narrative framing, and diverse characters (Alex, Pixie, Iris).
- **Classroom Diversity**: By offering adaptable difficulty levels and guided feedback for different learning styles.

Inspired by **CS Unplugged** activities, the app makes abstract concepts tactile through playful interaction. Each session lasts approximately 15–20 minutes, ideal for classrooms, workshops, or self-guided exploration.

### 🧑‍🎓 Educational Focus

- Binary Number Representation  
- Pixel-Based Image Encoding  
- RGB & Hex Color Systems  
- Computational Thinking & Playful Learning  

---

## 🧑‍💻 User Guide

### Getting Started

![Group 7](https://github.com/user-attachments/assets/f424ce06-c166-4197-a253-23577acd7c2a)

Upon launching Binary Spectrum, users are welcomed into a colorful, animated interface where they can select their avatar and begin exploring mini-games. Players can choose a difficulty level (Rookie or Pro) and navigate the app through a touch-friendly home screen.

### Mini-Games Overview

* **BitPearls**:
 ![Group 9](https://github.com/user-attachments/assets/51cb1218-f0ac-43a4-9416-ca0768add920)

  Learn binary encoding by creating a bracelet based on your birthday. Players toggle pearls on/off to form a binary pattern, then see its decimal and symbolic interpretations.

* **PixelPrism**:
  ![Group 10](https://github.com/user-attachments/assets/c8801d02-4d57-46f5-b2b1-1a221540ca7d)

  This game visualizes how images are formed from pixels. Players explore black-and-white pixel grids, draw their own images, and learn about resolution and data encoding.

* **ColorBloom**:
  ![Group 8](https://github.com/user-attachments/assets/01e5955f-2501-47c4-9da1-1b317eb6c6f6)

  Dive into the world of RGB color mixing. Players use sliders and hex codes to create colorful compositions, experimenting with opacity and additive color blending.

### Difficulty Modes

Binary Spectrum offers two distinct modes (future work):

* **Rookie Mode**:
  Designed for beginners.

* **Pro Mode**:
  Suitable for experienced learners, who are already familiar with the presented computational thinking concepts.

### Achievements and Progress

Players earn **badges** and **milestones** as they complete challenges, encouraging exploration and mastery. A built-in **progress tracker** allows users to review past activity and see what remains to be completed.

### Language Settings

Available in:
- 🇺🇸 English  
- 🇩🇪 German  
- 🇧🇷 Brazilian Portuguese  

---

## 💾 Installation

### Requirements

* macOS with Xcode 15.0 or later
* iOS 17.0 or later
* Swift 5.9

### Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/your-org/binary-spectrum.git
   ```

2. Open the project in Xcode:

   ```bash
   open EducationalGame.xcodeproj
   ```

3. Choose an iPad simulator or physical device (iOS 17+), then build and run the app. Play in landscape mode.

---

## 🛠 Development

### Architecture Overview

Binary Spectrum uses the **MVVM (Model-View-ViewModel)** architecture for maintainable, testable code. The structure enables clear separation of concerns and supports reactive UI updates.

### Code Structure

* **Models**: Core data types and logic
* **Views**: SwiftUI views for screens and components
* **ViewModels**: Bind UI with underlying models and handle user input/state
* **Services**: Sound effects, animations, localization, navigation
* **Utils**: Shared utility functions
* **Extensions**: Swift extensions for modular, reusable code

### Key Components

* `GameEngine.swift`: Core gameplay rules for each mini-game
* `AchievementsManager.swift`: Tracks and stores user progress
* `LocalizationService.swift`: Handles multi-language support
* `AudioFeedbackService.swift`: Controls sound feedback

## 🏗 Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture for clarity and maintainability:

- **Models**: Data structures and business logic
- **Views**: UI components and screens
- **ViewModels**: State management and view logic
- **Services**: Cross-cutting concerns (sound, haptics, navigation)
- **Utils**: Helper functions and utilities
- **Extensions**: Swift language extensions

| Layer         | Description                                     |
| ------------- | ----------------------------------------------- |
| `/Models`     | Binary math, pixel data, color values           |
| `/ViewModels` | Logic per game (e.g., BitPearlsViewModel.swift) |
| `/Views`      | SwiftUI screens and components                  |
| `/Services`   | Sound, navigation, progress                     |
| `/Assets`     | Visuals, audio, localizations                   |
| `/Utils`      | General-purpose functions                       |



