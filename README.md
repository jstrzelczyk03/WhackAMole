# Whack-A-Mole

Niniejsze repozytorium zawiera projekt gry "Whack-A-Mole", opracowany w ramach zajęć z programowania na platformę iOS. Projekt został zrealizowany przy użyciu Xcode, języka Swift oraz frameworka SwiftUI. Jego celem było zaprezentowanie podstawowych technik tworzenia interaktywnych aplikacji mobilnych oraz implementacji mechaniki gry.

## Struktura projektu

- **WhackAMole.xcodeproj**  
  Główny plik projektu zawierający konfigurację aplikacji oraz ustawienia kompilacji.

- **WhackAMole/**  
  - **ScoreManager.swift** – Klasa odpowiedzialna za zarządzanie punktacją w grze.
  - **Mole.swift** – Implementacja logiki kreta, w tym jego pojawianie się i znikanie.
  - **MoleShape.swift** – Definicja graficznego wyglądu kreta.
  - **WhackAMoleApp.swift** – Plik wejściowy aplikacji, inicjalizujący środowisko SwiftUI.
  - **GameViewModel.swift** – Klasa zarządzająca logiką gry oraz stanem rozgrywki.
  - **ContentView.swift** – Główny widok interfejsu użytkownika, umożliwiający interakcję z grą.

- **Assets.xcassets**  
  Zasoby graficzne wykorzystywane w aplikacji, takie jak obrazy tła, ikony oraz inne elementy wizualne.

- **Preview Content/**  
  Pliki umożliwiające podgląd widoków w czasie rzeczywistym w środowisku Xcode.

## Funkcjonalności

- **Interaktywna rozgrywka:**  
  Gra polega na szybkim reagowaniu na pojawiające się krety, które użytkownik powinien "uderzyć" w celu zdobywania punktów.

- **Losowy system pojawiania się kretów:**  
  Implementacja mechanizmu losowego pojawiania się kreta zapewnia zróżnicowany przebieg rozgrywki przy każdej sesji.

- **Nowoczesny interfejs użytkownika:**  
  Interfejs został zaprojektowany przy użyciu SwiftUI, co gwarantuje responsywność oraz estetyczny wygląd aplikacji.
