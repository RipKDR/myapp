
# Blueprint: NDIS Connect

This document outlines the vision, architecture, and implementation plan for the NDIS Connect application.

## 1. Project Overview

NDIS Connect is a mobile application designed to serve as an accessible, role-based companion for participants and providers in the National Disability Insurance Scheme (NDIS).

The app aims to provide a centralized platform for managing plans, connecting with providers, accessing resources, and fostering a supportive community.

## 2. Core Features

Based on the dependencies in `pubspec.yaml`, the application will be structured around the following core features:

*   **Authentication:** Secure user login and registration for participants and providers (using `firebase_auth`).
*   **Role-Based Access:** Different UI and features tailored to user roles (Participant, Provider, Carer).
*   **Service Discovery:** A map-based interface to find and connect with local NDIS providers (using `google_maps_flutter`).
*   **Plan Management:** Tools for participants to track their NDIS funding and goals (using `cloud_firestore` and visualized with `fl_chart`).
*   **Secure Communication:** Encrypted messaging or notes for private communication (using `cryptography`).
*   **Accessibility Features:** Voice-to-text, text-to-speech, and adjustable font sizes to ensure the app is usable for everyone (using `speech_to_text`, `flutter_tts`).
*   **Resource Library:** A repository of articles, guides, and news relevant to the NDIS community.
*   **Offline Access:** Caching of essential data for access without an internet connection (using `hive`).
*   **AI-Powered Assistance:** Smart features to simplify tasks, such as summarizing documents or suggesting providers (using `google_ml_kit`).

## 3. Recommended Architecture

To ensure the application is scalable, maintainable, and testable, we will adopt the following architectural principles:

*   **State Management:** We will use the `provider` package for robust and simple state management, separating UI from business logic.
*   **Feature-First Structure:** The code will be organized by feature (e.g., `lib/src/authentication`, `lib/src/map`, `lib/src/plan_management`) to keep the codebase clean and easy to navigate.
*   **Service Layer:** A dedicated service layer will abstract data operations (e.g., Firestore queries, API calls), making the app easier to test and maintain.
*   **Dependency Injection:** `provider` will also be used for dependency injection, making services available throughout the widget tree.
*   **Routing:** We will use a declarative routing solution like `go_router` for handling navigation, deep linking, and authentication-based redirects.

## 4. UI/UX Design

The user interface will be modern, intuitive, and accessible, following Material Design 3 principles.

*   **Theming:** A consistent theme with light and dark modes will be implemented. We'll use the `google_fonts` package for clean typography.
*   **Component Library:** We will create a set of reusable custom widgets for common UI elements to ensure consistency.
*   **Visual Appeal:** We will incorporate subtle animations (`lottie`, `flutter_staggered_animations`) and loading indicators (`shimmer`) to create a polished user experience.

## 5. Improvement Plan: Phase 2 (Make)

The first step is to replace the current boilerplate code with a solid application foundation.

**Current Step:** Restructure the application foundation.

*   **Objective:** Replace the default counter app with a well-structured shell for the NDIS Connect app.
*   **Actions:**
    1.  Add `google_fonts` and `go_router` to `pubspec.yaml`.
    2.  Create a `lib/src` directory to house all feature-based code.
    3.  Refactor `lib/main.dart` to:
        *   Initialize Firebase.
        *   Set up a `ThemeProvider` using `provider`.
        *   Configure `go_router` with initial routes.
        *   Define a Material 3 theme with `ColorScheme.fromSeed` and `google_fonts`.
    4.  Create an initial `HomeScreen` with a basic layout reflecting the app's purpose.
    5.  Create dedicated directories for key features like `authentication`, `core`, and `home`.
