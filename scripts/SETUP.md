# Konfiguracja środowiska – bursa_app

Instrukcja przygotowania komputera do pracy nad projektem.

---

## Szybki start (Windows)

> Cały setup to **3 kroki**. Skrypt sam instaluje brakujące narzędzia i pomija to, co już masz.

### 1. Sklonuj repozytorium

Repozytorium jest prywatne – poproś właściciela o dodanie Cię jako *collaborator* na GitHubie i zaakceptuj zaproszenie z maila.

```powershell
git clone https://github.com/Mikosztyla/SystemyMobilne.git C:\dev\studia\SM
```

Nie masz gita? Pobierz ZIP z GitHuba (**Code → Download ZIP**), rozpakuj do `C:\dev\studia\SM` – skrypt z kroku 2 doinstaluje gita.

### 2. Uruchom `scripts/setup.bat`

W folderze projektu wejdź do **`scripts`** i kliknij dwukrotnie **`setup.bat`**. Skrypt:

| Krok | Co robi |
|---|---|
| Git | instaluje przez `winget`, jeśli brak |
| Android Studio | instaluje przez `winget`, jeśli brak |
| Flutter SDK | pobiera kanał *stable* do `C:\dev\flutter` i dodaje do `PATH` |
| Tryb dewelopera | sprawdza i w razie potrzeby otwiera Ustawienia Windows |
| Android SDK | prowadzi przez pierwsze uruchomienie Android Studio (patrz niżej) |
| `flutter doctor` | pokazuje stan środowiska |
| `flutter pub get` | pobiera zależności projektu |

**Jedyna rzecz do wyklikania ręcznie** – skrypt otworzy Android Studio i poczeka:

1. Przy pierwszym uruchomieniu wybierz **Standard** i poczekaj na pobranie SDK.
2. Ekran powitalny → **More Actions → SDK Manager → zakładka „SDK Tools”** → zaznacz **Android SDK Command-line Tools (latest)** → **Apply**.
3. **More Actions → Virtual Device Manager → „+”** → wybierz np. Pixel z najnowszym Androidem → utwórz emulator.
4. Wróć do okna skryptu i naciśnij Enter.

Jeśli Windows pokaże ostrzeżenie SmartScreen: **Więcej informacji → Uruchom mimo to**.

### 3. Uruchom aplikację

Otwórz **nowy** terminal (żeby odświeżył się `PATH`), uruchom emulator (Android Studio → Device Manager → ▶) i:

```powershell
cd C:\dev\studia\SM
flutter run
```

Pierwszy build trwa kilka minut (Gradle pobiera zależności), kolejne są szybkie. Podczas działania `r` = hot reload, `R` = restart, `q` = wyjście.

---

## IDE

Działa dowolne z poniższych – wystarczy zainstalować plugin **Flutter** (plugin Dart doinstaluje się sam):

- **IntelliJ IDEA** (Community wystarczy) – Settings → Plugins → *Flutter*, potem Settings → Languages & Frameworks → Flutter → *Flutter SDK path* = `C:\dev\flutter`.
- **Android Studio** – to samo co wyżej.
- **VS Code** – rozszerzenie *Flutter*.

Projekt otwierasz przez **File → Open** i wskazujesz folder repozytorium. Urządzenie (emulator/telefon) wybierasz na pasku narzędzi, uruchamiasz zielonym ▶.

## Telefon zamiast emulatora

Do testowania skanera QR wygodniej użyć prawdziwego telefonu z Androidem:

1. Ustawienia → Informacje o telefonie → 7× stuknij w **Numer kompilacji** (włącza opcje programisty).
2. Opcje programisty → włącz **Debugowanie USB**.
3. Podłącz kabel, zaakceptuj komunikat na telefonie. `flutter devices` powinien go pokazać.

---

## Codzienna praca

| Co | Jak |
|---|---|
| Uruchomienie aplikacji | `flutter run` |
| Analiza kodu + testy | dwuklik **`scripts/check.bat`** (albo `flutter analyze` i `flutter test`) |
| Nowa zależność | `flutter pub add nazwa_pakietu` |
| Po `git pull` | `flutter pub get` (IntelliJ zwykle podpowiada sam) |

### Git

- `main` zawsze powinien się budować i przechodzić testy.
- Każdą funkcję rób na osobnej gałęzi: `git switch -c feature/nazwa-funkcji`.
- Przed wysłaniem uruchom `scripts/check.bat`, potem `git push -u origin feature/nazwa-funkcji` i otwórz Pull Request na GitHubie.

---

## Struktura projektu

```
lib/              kod aplikacji (Dart)
test/             testy
android/, ios/    konfiguracja platform (zwykle nie trzeba tu zaglądać)
scripts/          setup.bat (konfiguracja środowiska), check.bat (analiza + testy), ta instrukcja
.claude/skills/   skille Fluttera dla Claude Code (asystent AI)
```

Kod w `lib/` jest podzielony warstwowo (wzorzec MVVM z oficjalnych zaleceń Fluttera):

```
lib/
├── domain/models/        modele danych
├── data/repositories/    dostęp do danych (Firebase / dane testowe)
├── routing/              nawigacja (go_router)
└── ui/
    ├── core/             motyw, wspólne widżety
    └── features/<nazwa>/ views/ (ekrany) + view_models/ (logika ekranu)
```

### Użyte technologie

| Pakiet | Do czego |
|---|---|
| `go_router` | nawigacja między ekranami |
| `provider` | wstrzykiwanie zależności i stan (ViewModele) |
| `intl`, `flutter_localizations` | polskie daty, kwoty i teksty systemowe |
| `mobile_scanner` | skanowanie kodów QR na pralkach |
| `flutter_local_notifications` | przypomnienia o dyżurach |

Projekt był tworzony na **Flutter 3.47.7 / Dart 3.13**. Nowsza wersja *stable* też powinna działać.

---

## Rozwiązywanie problemów

**`flutter` nie jest rozpoznawane jako polecenie** – zamknij i otwórz terminal (albo IDE) po instalacji. Jeśli dalej nie działa, dodaj `C:\dev\flutter\bin` do zmiennej `PATH` użytkownika.

**`Android sdkmanager not found` / `cmdline-tools component is missing`** – w Android Studio: More Actions → SDK Manager → SDK Tools → zaznacz *Android SDK Command-line Tools (latest)* → Apply.

**`The --licenses option is no longer needed`** przy `flutter doctor --android-licenses` – to nie błąd, nowe narzędzia Androida nie wymagają już akceptowania licencji.

**`Building with plugins requires symlink support`** – włącz Tryb dewelopera: Ustawienia → System → Dla deweloperów.

**Emulator działa bardzo wolno** – włącz wirtualizację w BIOS-ie oraz funkcję Windows *Windows Hypervisor Platform* (Panel sterowania → Włącz lub wyłącz funkcje systemu Windows).

**`flutter doctor` pokazuje błąd przy Xcode / iOS** – na Windowsie nie da się budować na iPhone'a, to normalne. Wersję na iOS można zbudować tylko na Macu.

**Na macOS / Linux** – zainstaluj ręcznie: [Flutter](https://docs.flutter.dev/get-started/install), [Android Studio](https://developer.android.com/studio) (z Command-line Tools), potem w folderze projektu `flutter doctor` i `flutter pub get`.
